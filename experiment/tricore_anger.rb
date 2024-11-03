# Check this idea works OK for the original use case: finding the `mov.a` and `mov.d` instructions

require 'json'
require_relative 'llvm_utils'

instructions = load_instructions('TriCore') 

instructions.each do |_, ins|
  # Try to find "something which takes a data register, and outputs into an address register"
  if unwrap_flat_dag(ins['InOperandList']).find { |ty, _| ty.include?('Data') } &&
     unwrap_flat_dag(ins['OutOperandList']).find { |ty, _| ty.include?('Addr') }

     puts ins['AsmString']
  end
end
