require 'json'

def load_instructions(arch)
  JSON.parse(File.read(File.join(__dir__, '..', 'tblgen_dump', "#{arch}.json")))
    .select { |_, ins| is_instruction?(ins) }
    .reject { |_, ins| ins['isPseudo'] == 1 }
end

# Unwrap { 'kind' => 'def', 'def' => X } into X
def unwrap_def(d)
  raise "Not a def: #{d}" unless d['kind'] == 'def'
  d['def']
end

# Unwrap { 'kind' => 'def', 'def' => X } into X
def unwrap_defs(arr)
  arr.map { |d| unwrap_def(d) }
end

# Assume a DAG is a flat array of defs, ignore the operator, and return [[type, name], ...]
def unwrap_flat_dag(dag)
  raise "not a DAG: #{dag}" unless dag['kind'] == 'dag'
  dag['args'].map do |(type, name)|
    [unwrap_def(type), name]
  end
end

# Is this a concrete record representing an instruction?
def is_instruction?(record)
  record.is_a?(Hash) && record['!superclasses'] && record['!superclasses'].include?('Instruction')
end

# ChatGPT rubbish (what on earth are $` and $')
def brace_permutations(s)
  return [] if s.nil? || s.empty? 

  if s =~ /\{([^}]+)\}/
    pre, inner, post = $`, $1, $'
    brace_permutations(pre + post).concat(brace_permutations(pre + inner + post))
  else
    [s]
  end
end

# Get all possible mnemonics for an instruction
def mnemonics(ins)
  template = ins['AsmString'].split
  brace_permutations(template[0])
end

def dump_instruction(ins)
  in_ops = unwrap_flat_dag(ins['InOperandList'])
  out_ops = unwrap_flat_dag(ins['OutOperandList'])
  uses = unwrap_defs(ins['Uses'])
  defs = unwrap_defs(ins['Defs'])

  puts "#{ins['!name']} ".ljust(80, '=')
  puts
  puts "  #{ins['AsmString']}"
  puts
  puts "  INPUTS"
  puts "    Operands: #{in_ops.map { |ty, name| "#{name}:#{ty}" }.join(', ')}" if in_ops.any?
  puts "    Implicit: #{uses.join(', ')}" if uses.any?
  puts "    Memory:   #{ins['mayLoad'] ? 'YES' : 'no'}"
  puts "  OUTPUTS"
  puts "    Operands: #{out_ops.map { |ty, name| "#{name}:#{ty}" }.join(', ')}" if out_ops
  puts "    Implicit: #{defs.join(', ')}" if defs.any?
  puts "    Memory:   #{ins['mayStore'] ? 'YES' : 'no'}"
  puts
end
