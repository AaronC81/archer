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

      apply_constraints(defi.fetch('Constraints'))
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

    # Fixes up an instruction, during loading from TableGen, to apply LLVM operand constraints.
    #
    # LLVM does not appear(?) to be able to model a single operand which is both an input and an
    # output. For example, a two operand add:
    #
    #   add $acc, $val
    #
    # Maybe be in fact modelled as:
    #
    #   asm: "add $acc, $val"
    #   inputs: $acc, $val
    #   outputs: $dest
    #   constraint: $dest = $acc
    #
    # This is unintuitive if you don't care about LLVM's semantics - you'll see `$dest` in the list
    # of operands, despite the fact it doesn't appear in the Assembly string.
    #
    # This method will retroactively fix up the input and output operands, so that you're only left
    # with the ones that appear in the Assembly string:
    #
    #   asm: "add $acc, $val"
    #   inputs: $acc, $val
    #   outputs: $acc
    # 
    # This breaks the direct relationship with the LLVM TableGen data, but improves usability, so
    # it's worth doing.
    private def apply_constraints(constraints)
      return if constraints.strip.empty?

      # We only currently support the constraint "$x = $y"
      unless /^\s*\$([A-Za-z0-9]+)\s*=\s*\$([A-Za-z0-9]+)\s*$/ === constraints
        puts "WARNING: Dropping unknown constraint applied to `#{name}`: `#{constraints}`"
        return
      end

      left = $1
      right = $2

      # Figure out which of the two sides of the constraint actually appears in the Assembly string
      operands_in_asm = assembly_format
        .scan(/\$[A-Za-z0-9]+/)
        .map { |op| op[1..-1] } # Drop leading $

      if operands_in_asm.include?(left) && operands_in_asm.include?(right)
        # Ah, they're both mentioned! why is there a constraint then?
        # Whatever. Leave things as they are
        return
      elsif operands_in_asm.include?(left)
        rename_operand(old_name: right, new_name: left)
      elsif operands_in_asm.include?(right)
        rename_operand(old_name: left, new_name: right)
      else
        # Neither operand is in the assembly! huh?
        puts "WARNING: Operands in `#{name}` involved in constraint do not exist in Assembly string: `#{constraints}`"
      end
    end

    # Find occurrences of an input/output operand and rename it.
    private def rename_operand(old_name:, new_name:)
      @inputs.each  { |op| op.name = new_name if op.name == old_name }
      @outputs.each { |op| op.name = new_name if op.name == old_name }
    end
  end
end
