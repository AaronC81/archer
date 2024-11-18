class Target
  class ExplodableOperandType
    def initialize(inner_operand_types, format)
      @inner_operand_types = inner_operand_types
      @format = format
    end

    # @return [<String, SupplementaryData::OperandType>]
    attr_reader :inner_operand_types

    # @return [String]
    attr_reader :format

    # @return [<Instruction::Operand>]
    def create_operands(basename)
      inner_operand_types
        .map { |name, ty| Instruction::Operand.new("#{basename}.#{name}", ty) }
    end

    # @return [String]
    def substitute_string(operands)
      str = format.dup
      operands.each.with_index do |op, i|
        str = str.gsub("$#{i}", "$#{op.name}")
      end
      str
    end
  end
end
