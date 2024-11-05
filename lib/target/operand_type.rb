class Target
  # An abstract type of operand accepted by an instruction. 
  class OperandType
    def initialize
      raise 'abstract'
    end

    def self.from_def(defi)
      raise "not an operand" unless defi.is_subclass?(:Operand)

      ty = defi.fetch(:OperandType)
      case ty

      when 'OPERAND_IMMEDIATE'
        ImmediateOperandType.new(defi.name)

      when 'OPERAND_MEMORY'
        MemoryOperandType.new(defi.name)

      when 'OPERAND_UNKNOWN'
        composed_of = defi.fetch(:MIOperandInfo).to_array.map(&:value)
        if composed_of.empty?
          puts "WARNING: Dropping operand type `#{defi.name}` with UNKNOWN type but no composite definitions"
          return nil
        end
        
        # TODO: resolve later, like register classes
        CompositeOperandType.new(defi.name, composed_of)

      else
        puts "WARNING: Dropping operand type `#{defi.name}` with unsupported type `#{ty}`"
        nil

      end
    end

    # @return [Symbol] LLVM's internal name for this operand type.
    attr_reader :name

    # Flatten a complex nested operand type, for searching purposes.
    # @return [<OperandType>]
    def flatten
      [self]
    end
  end

  # An immediate operand type.
  class ImmediateOperandType < OperandType
    def initialize(name)
      @name = name
    end
  end

  # An operand type which references a specific region of memory.
  class MemoryOperandType < OperandType
    def initialize(name)
      @name = name
    end
  end

  # An operand type which is some unknown composite of other operand types.
  #
  # While we can't handle this specifically, it's useful to know for searching.
  # For example, TriCore does not use any memory operands directly - instead it defines a composite
  # of a memory operand and an offset immediate.
  class CompositeOperandType < OperandType
    def initialize(name, operands)
      @name = name
      @operands = operands
    end
    
    # @return [<OperandType>] The other operands which compose this one.
    attr_reader :operands

    def flatten
      operands
    end
  end
end
