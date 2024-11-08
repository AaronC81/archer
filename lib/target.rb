require_relative 'target/register'
require_relative 'target/register_class'
require_relative 'target/instruction'
require_relative 'target/operand_type'

class Target
  def initialize(name, dump)
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

    @operand_types = dump.definitions(of: :Operand)
      .map { |d| OperandType.from_def(d) }
      .compact
      .map { |ty| [ty.name, ty] }
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
  attr_reader :operand_types

  # @return [<Instruction>]
  attr_reader :instructions

  def fetch_register(name)
    registers.fetch(name.to_sym)
  end

  def fetch_register_class(name)
    register_classes.fetch(name.to_sym)
  end
end
