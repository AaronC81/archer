# Search for instructions by mnemonic and dump some info

require_relative 'llvm_utils'

instructions = load_instructions("X86")
puts "Loaded"

mnemonic = "add"

instructions.each do |_, ins|
  if mnemonics(ins).include?(mnemonic)
    dump_instruction(ins)
  end
end
