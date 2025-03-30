private def operand_filter(name, type)
  find("#operand-filter-table")                     # Find the table...
    .find("tr", text: name)                         # ...then the specific row we're after...
    .find("td input.input-operand-#{type}-filter")  # ...then, in that row, the specific input
end

def input_operand_filter(name) = operand_filter(name, 'input')
def output_operand_filter(name) = operand_filter(name, 'output')
  
def no_input_operands_filter = find(id: 'input-operand-input-none-filter')
def no_output_operands_filter = find(id: 'input-operand-output-none-filter')
  
def memory_store_filter = find(id: 'input-store-filter')
def memory_load_filter = find(id: 'input-load-filter')

def mnemonic_filter = find(id: 'input-mnemonic-filter')

def predicate_filter(name)
  find("#predicate-filter-table")
    .find("tr", text: name)
    .find("td input")
end