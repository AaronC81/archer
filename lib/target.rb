require_relative 'target/register'
require_relative 'target/register_class'
require_relative 'target/instruction'
require_relative 'supp'

class Target
  def initialize(name, dump, supp)
    @name = name

    @registers = dump.definitions(of: :Register)
      .map { |d| Register.new(d) }
      .map { |reg| [reg.name, reg] }
      .to_h

    @register_classes = dump.definitions(of: :RegisterClass)
      .map { |d| RegisterClass.new(d) }
      .map { |regc| [regc.name, regc] }
      .to_h
    @register_classes.each { |_, c| c.resolve_members(self) }

    @operand_types = supp.operand_types
      .map { |ty| [ty.llvm_name, ty] }
      .to_h
    @operand_types['unknown!'] = SupplementaryData::OperandType.new_unknown

    @operand_type_families = supp.operand_type_families
      .map { |fam| [fam.name, fam] }
      .to_h

    @instructions = dump.definitions(of: :Instruction)
      .map { |d| Instruction.new(d, self) }
      .reject { |i| i.pseudo? }
      .map { |i| [i.name, i] }
      .to_h
  end

  attr_reader :name
  attr_reader :registers
  attr_reader :register_classes

  # @return [{ String => SupplementaryData::OperandType }]
  attr_reader :operand_types

  # @return [{ String => SupplementaryData::OperandTypeFamily }]
  attr_reader :operand_type_families

  # @return [{ String => Instruction }]
  attr_reader :instructions

  def fetch_register(name)
    registers.fetch(name.to_sym)
  end
end
