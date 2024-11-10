require 'yaml'

# Suplementary architecture data, which helps make the TableGen info "friendlier."
class SupplementaryData
  def initialize(data)
    @operand_types = data.fetch('operand_types')
      .flat_map do |key, ty|
        if key == "expand_immediates!"
          ty.map { |imm| OperandType.from_immediate(imm) }
        else
          [OperandType.new(ty)]
        end
      end

    @operand_type_families = operand_types
      .reject { |ty| ty.family.nil? }
      .group_by(&:family)
      .map { |name, members| OperandTypeFamily.new(name, members) }
  end

  def self.load(file)
    new(YAML.load(File.read(file)))
  end

  # @return [<OperandType>]
  attr_reader :operand_types

  # @return [<OperandTypeFamily>]
  attr_reader :operand_type_families

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
  end
end
