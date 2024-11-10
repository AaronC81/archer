# Tally operand types across all instructions

require 'json'
require_relative 'llvm_utils'

instructions = load_instructions('TriCore')

$types = {}
def add_to_count(tys)
  tys.each do |ty|
    $types[ty] ||= 0
    $types[ty] += 1
  end
end

instructions.each do |_, ins|
  next unless is_instruction?(ins)

  add_to_count unwrap_flat_dag(ins['InOperandList']).map(&:first)
  add_to_count unwrap_flat_dag(ins['OutOperandList']).map(&:first)
end

pp $types.sort_by { |_, count| count }.reverse
