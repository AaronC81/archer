def input_operand_filter(name) = find(".input-operand-input-filter[data-operand-name=\"#{name}\"]")
def output_operand_filter(name) = find(".input-operand-output-filter[data-operand-name=\"#{name}\"]")
  
def no_input_operands_filter = find(id: 'input-operand-input-none-filter')
def no_output_operands_filter = find(id: 'input-operand-output-none-filter')
  
def memory_store_filter = find(id: 'input-store-filter')
def memory_load_filter = find(id: 'input-load-filter')
  