require_relative 'assembly_format_parser'

class Target
  # A specific variant of an instruction, as understood by LLVM.
  class Instruction
    def initialize(defi, target)
      @name = defi.name
      # p name
      @raw_assembly_format = defi.fetch('AsmString')

      @may_store = defi.fetch_bool('mayStore')
      @may_load = defi.fetch_bool('mayLoad')

      @inputs, @raw_assembly_format = process_operand_list(target, defi.fetch('InOperandList'), @raw_assembly_format)
      @outputs, @raw_assembly_format = process_operand_list(target, defi.fetch('OutOperandList'), @raw_assembly_format)

      @assembly_format = AssemblyFormatParser.parse(@raw_assembly_format)

      @implicitly_read_registers = defi.fetch('Uses').map { |reg| target.fetch_register(reg) }
      @implicitly_written_registers = defi.fetch('Defs').map { |reg| target.fetch_register(reg) }

      @predicates = defi.fetch('Predicates')
      @pseudo = defi.fetch_bool('isPseudo')
      @documentation = target.documentation_provider.documentation_url(self)

      apply_constraints(defi.fetch('Constraints'))
    end

    # @return [Symbol] LLVM's internal name for this instruction.
    attr_reader :name

    # @return [String] The raw pattern of available assembly formats for this instruction.
    #   Depending on the architecture, this may represent multiple permitted forms.
    attr_reader :raw_assembly_format

    # @return [AssemblyFormatParser::Node] The parsed assembly format for this instruction.
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

    # @return [<Symbol>] A list of LLVM names for predicates which must be fulfilled for this
    #   instruction to be used. These are usually extensions that the processor must support, or
    #   modes that it must be in.
    attr_reader :predicates

    # @return [Documentation::Link, nil] This instruction's documentation, if it has any.
    attr_reader :documentation

    Operand = Struct.new('Operand',
      # [String] The name of the operand. 
      :name,

      # [SupplementaryData::OperandType] The operand's type.
      :operand_type,
    )

    # @return [(<Operand>, String)]
    def process_operand_list(target, dag, assembly_format)
      operands = dag.arguments.flat_map do |arg|
        if arg.value.is_a?(Symbol)
          # Simple case - it's just a simple named operand
          [Operand.new(arg.name, look_up_operand_type(arg.value, target))]
        elsif arg.value.is_a?(TableGen::Value::Dag)
          # Nested argument time!
          # We need to have been told how to explode this operand.
          complex_arg_name = arg.value.operator
          explode_ty = target.explodable_operand_types[complex_arg_name]
          if explode_ty
            ops = explode_ty.create_operands(arg.name)
            new_assembly_format_fragment = explode_ty.substitute_string(ops)

            # TODO: less error-prone substitution
            assembly_format = assembly_format.gsub("$#{arg.name}", new_assembly_format_fragment)

            ops
          else
            raise "don't know how to explode nested operand type `#{complex_arg_name}` in instruction `#{name}`"
          end
        end
      end

      [operands, assembly_format]
    end

    # Split up this instruction's `#assembly_format` into its constituent parts. This can be used
    # to style different parts of the format differently.
    #
    # Returns an array of:
    #   - `[:text, String]` - A raw text part of the Assembly string.
    #   - `[:operand, Operand]` - A reference to one of this instruction's operands.
    def assembly_parts_for_variant(variant)
      parts = []

      assembly_format.walk(variant) do |node|
        case node
        when AssemblyFormatParser::Text
          parts << [:text, node.text]
        when AssemblyFormatParser::Operand
          parts << [:operand, find_operand(node.name)]
        else
          raise 'unexpected leaf type'
        end 
      end

      parts
    end

    def assembly_format_for_variant(variant)
      str = ""
      assembly_format.walk(variant) do |node|
        case node
        when AssemblyFormatParser::Text
          str += node.text
        when AssemblyFormatParser::Operand
          str += node.name
        else
          raise 'unexpected leaf type'
        end
      end

      str
    end

    private def look_up_operand_type(name, target)
      target.fetch_operand_type(name)
    end

    # @param fixup [SupplementaryData::InstructionFixup] 
    def apply_fixup(fixup)
      return unless fixup.match === name

      LoadLogger.info "Fixup applied to `#{name}`: #{fixup.desc}"

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

      # Multiple constraints can be separated by commas
      constraints.split(',').map(&:strip).each do |constraint|
        # Nothing to do with the `@earlyclobber` constraint
        next if constraint.start_with?('@earlyclobber ')

        # Besides that, we only currently support the constraint "$x = $y"
        unless /^\s*\$([A-Za-z0-9_\.]+)\s*=\s*\$([A-Za-z0-9_\.]+)\s*$/ === constraint
          LoadLogger.warn "Dropping unknown constraint applied to `#{name}`: `#{constraint}`"
          next
        end

        left = $1
        right = $2

        # Figure out which of the two sides of the constraint actually appears in the Assembly string
        operands_in_asm = []
        assembly_format.walk(nil) do |node|
          operands_in_asm << node.name if node.is_a?(AssemblyFormatParser::Operand)
        end

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
          LoadLogger.warn "Operands in `#{name}` involved in constraint do not exist in Assembly string: `#{constraints}`"
        end
      end
    end

    # Find occurrences of an input/output operand and rename it.
    private def rename_operand(old_name:, new_name:)
      @inputs.each  { |op| op.name = new_name if op.name == old_name }
      @outputs.each { |op| op.name = new_name if op.name == old_name }
    end

    # Find an operand by name.
    # @raise [KeyError]
    # @return [Operand]
    private def find_operand(name)
      @inputs.find { |op| op.name == name } || @outputs.find { |op| op.name == name } || (raise "no operand named `#{name}` in instruction `#{self.name}`")
    end
  end
end
