require 'yaml'
require_relative 'colours'

# Suplementary architecture data, which helps make the TableGen info "friendlier."
class SupplementaryData
  def initialize(data)
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
  end

  def self.load(file)
    new(YAML.load(File.read(file)))
  end

  # @return [<OperandType>]
  attr_reader :operand_types

  # @return [<OperandTypeFamily>]
  attr_reader :operand_type_families

  # @return [<InstructionFixup>]
  attr_reader :instruction_fixups

  # @return [<String>]
  attr_reader :assembly_variants

  class OperandType
    def initialize(data)
      @friendly_name = data.fetch('friendly_name')
      @llvm_name = data.fetch('llvm_name').to_sym
      @family = data.fetch('family')
    end

    def self.from_immediate(llvm_name)
      raise "malformed immediate name" unless /^([siu])(\d+)imm$/ === llvm_name
      bits = $2.to_i
      form = case $1
        when 's'; 'Sign-extended '
        when 'u'; 'Zero-extended '
        when 'i'; ''
      end

      new({
        'friendly_name' => "#{form}#{bits}-bit immediate",
        'llvm_name' => llvm_name,
        'family' => 'Immediate',
      })
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
end
