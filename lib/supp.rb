require 'yaml'
require_relative 'colours'

# Ensure that any requested documentation provider is already imported
Dir[File.join(__dir__, 'documentation', '*.rb')].each do |rb|
  require_relative rb
end

# Suplementary architecture data, which helps make the TableGen info "friendlier."
class SupplementaryData
  def initialize(data)
    @title = data.fetch('title')
    @subtitle = data['subtitle']

    @documentation_provider =
      if data['documentation_provider']
        Documentation.const_get(data['documentation_provider'].to_sym).new
      else
        Documentation::NoneProvider.new
      end

    @operand_types = data.fetch('operand_types')
      .flat_map do |key, ty|
        case key
        when "expand_immediates!"
          ty.map { |imm| OperandType.from_immediate(imm) }
        when "expand_memory!"
          ty.map { |mem| OperandType.from_memory(mem) }
        else
          [OperandType.new(ty)]
        end
      end

    @operand_type_families = operand_types
      .reject { |ty| ty.family.nil? }
      .group_by(&:family)
      .map { |name, members| OperandTypeFamily.new(name, members) }

    @instruction_fixups = data.fetch('instruction_fixups')
      .map do |fixup|
        InstructionFixup.new(
          Regexp.new(fixup.fetch('match')),
          fixup.fetch('modify')
            .map { |k, v| [k.to_sym, v] }
            .to_h
        )
      end

    @assembly_variants = data['assembly_variants'] || ['Default']

    @predicates = (data['predicates'] || [])
      .flat_map do |pred|
        # Supports specifying multiple LLVM names, as some architectures have some overlap that we
        # don't care about (e.g. `UseSSE1` vs `HasSSE1`)
        llvm_names = pred.fetch('llvm_name')
        llvm_names = [llvm_names] unless llvm_names.is_a?(Array)

        llvm_names.map do |llvm_name|
          Predicate.new(llvm_name.to_sym, pred.fetch('friendly_name'))
        end
      end
  end

  def self.load(file)
    new(YAML.load(File.read(file)))
  end

  # @return [String]
  attr_reader :title

  # @return [String, nil]
  attr_reader :subtitle

  # @return [<OperandType>]
  attr_reader :operand_types

  # @return [<OperandTypeFamily>]
  attr_reader :operand_type_families

  # @return [<InstructionFixup>]
  attr_reader :instruction_fixups

  # @return [<String>]
  attr_reader :assembly_variants

  # @return [<Predicate>]
  attr_reader :predicates

  # @return [Documentation::Provider]
  attr_reader :documentation_provider

  class OperandType
    def initialize(data)
      @friendly_name = data.fetch('friendly_name')
      @llvm_name = data.fetch('llvm_name').to_sym
      @family = data.fetch('family')
    end

    def self.from_immediate(llvm_name)
      case llvm_name
      when /^([siu])((?<size>\d+)imm|imm(?<size>\d+))$/ # sometimes "u1imm", sometimes "uimm1"
        bits = $~['size'].to_i
        form = case $1
          when 's'; 'Signed '
          when 'u'; 'Unsigned '
          when 'i'; ''
        end

        new({
          'friendly_name' => "#{form}#{bits}-bit immediate",
          'llvm_name' => llvm_name,
          'family' => 'Immediate',
        })

      when /^([iu])(\d+)([iu])(\d+)imm$/
        to_bits = $2.to_i
        from_form = case $3
          when 's'; 'Signed '
          when 'u'; 'Unsigned '
          when 'i'; ''
        end
        from_bits = $4.to_i

        new({
          'friendly_name' => "#{from_form}#{from_bits}-bit immediate (extended to #{to_bits}-bit)",
          'llvm_name' => llvm_name,
          'family' => 'Immediate',
        })

      else
        raise "unknown immediate #{llvm_name}"
      end
    end

    def self.from_memory(llvm_name)
      raise "malformed memory name" unless /^([fi])(\d+)mem$/ === llvm_name
      bits = $2.to_i
      ty = case $1
        when 'f'; 'float'
        when 'i'; 'integer'
      end

      new({
        'friendly_name' => "Memory reference to #{ty} (#{bits}-bit width)",
        'llvm_name' => llvm_name,
        'family' => 'Memory',
      })
    end

    def self.new_unknown
      new({
        'friendly_name' => 'Unknown',
        'llvm_name' => 'unknown!',
        'family' => nil,
      })
    end

    # @return [String]
    attr_reader :friendly_name

    # @return [Symbol]
    attr_reader :llvm_name

    # @return [String]
    attr_reader :family
  end

  class OperandTypeFamily
    def initialize(name, members)
      @name = name
      @members = members
    end

    attr_reader :name
    attr_reader :members

    def colour
      Colours::OPERAND_FAMILY_COLOURS[name] || Colours::DEFAULT
    end
  end

  class InstructionFixup
    def initialize(match, modify)
      @match = match
      @modify = modify
    end

    # @return [Regexp]
    attr_reader :match

    # @return [{ Symbol => Object }]
    attr_reader :modify
  end

  Predicate = Struct.new('Predicate',
    # [Symbol]
    :llvm_name,

    # [String]
    :friendly_name,
  )
end
