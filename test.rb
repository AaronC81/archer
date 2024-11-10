require_relative 'lib/tablegen/dump'
require_relative 'lib/target'

require 'json'

dump = TableGen::Dump.load(File.join(__dir__, 'tblgen_dump', 'X86.json'))

target = Target.new("X86", dump)
# p target.fetch_register_class(:GR8)
p target.operand_types

# defs = JSON.parse(File.read(File.join(__dir__, 'tblgen_dump', 'X86.json')))
  # .select { |key, value| value.is_a?(Hash) && !key.start_with?('!') }
  # .map { |key, value| [key.to_sym, TableGen::Definition.new(value)] }
  # .to_h


# p defs.select { |_, v| v.is_subclass?(:Register) }.map(&:first)
# p defs.select { |_, v| v.is_subclass?(:RegisterClass) }.map(&:first)

# p defs[:GR8]

# p defs[:ADD8rr].superclasses
# p defs[:ADD8rr]['InOperandList'].to_array
