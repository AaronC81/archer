class Target
  # A specific variant of an instruction, as understood by LLVM.

  # TODO: exclude pseudoinstructions
  class Instruction
    def initialize(defi, target)
      @name = defi.name
      @assembly_format = defi.fetch('AsmString')

      @may_store = defi.fetch_bool('mayStore')
      @may_load = defi.fetch_bool('mayLoad')

      @inputs = defi.fetch('InOperandList')
        .to_array
        .map { |op| Operand.new(op.name, look_up_operand_type(op.value, target)) }
      @outputs = defi.fetch('OutOperandList')
        .to_array
        .map { |op| Operand.new(op.name, look_up_operand_type(op.value, target)) }

      @implicitly_read_registers = defi.fetch('Uses').map { |reg| target.fetch_register(reg) }
      @implicitly_written_registers = defi.fetch('Defs').map { |reg| target.fetch_register(reg) }

      @pseudo = defi.fetch_bool('isPseudo')
    end

    # @return [Symbol] LLVM's internal name for this instruction.
    attr_reader :name

    # @return [String] The pattern of available assembly formats for this instruction.
    #   Depending on the architecture, this may represent multiple permitted forms.
    attr_reader :assembly_format

    # @return [Boolean] Whether this instruction can write to memory.
    def may_store?; @may_store; end

    # @return [Boolean] Whether this instruction can read from memory.
    def may_load?; @may_load; end

    # @return [Boolean] Whether this instruction is a psuedoinstruction - that is, a non-machine
    #   instruction used to help model LLVM's codegen.
    def pseudo?; @pseudo; end

    # @return [<Operand>] A list of input operands for this instruction.
    attr_reader :inputs

    # @return [<Operand>] A list of input operands for this instruction.
    attr_reader :outputs

    # @return [<Register>] Registers which may be accessed by this instruction, despite not being
    #   listed as operands.
    attr_reader :implicitly_read_registers

    # @return [<Registers>] Registers which may be written by this instruction, despite not being
    #   listed as operands.
    attr_reader :implicitly_written_registers

    Operand = Struct.new('Operand',
      # [String] The name of the operand. 
      :name,

      # [SupplementaryData::OperandType] The operand's type.
      :operand_type,
    )

    private def look_up_operand_type(name, target)
      target.fetch_operand_type(name)
    end

    # @param fixup [SupplementaryData::InstructionFixup] 
    def apply_fixup(fixup)
      return unless fixup.match === name

      fixup.modify.each do |var, value|
        instance_variable_set(var, value)
      end
    end
  end
end
