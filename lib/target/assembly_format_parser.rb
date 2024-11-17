class Target
  module AssemblyFormatParser
    # Base class for Assembly format parser nodes.
    class Node
      # Perform a depth-first traversal of the leaf nodes for a particular variant.
      #
      # This can be used to build up a textual representation of the Assembly format.
      #
      # By default, this simply yields the current node.
      # It should be overridden by any nodes which branch on variant or contain other nodes.
      #
      # @param variant [Integer, nil] The variant number to select. If nil, all variants - rarely
      #   useful for rendering, instead useful for data processing.
      # @yieldparam [Node] All involved nodes, one after the other, from left to right.
      def walk(variant)
        yield self
      end
    end

    # Represents some unchanging, literal text with no particular semantic meaning.
    class Text < Node
      def initialize(text)
        @text = text
      end

      # @return [String]
      attr_reader :text
    end

    # Represents an operand within the instruction.
    # Operands in the tree do not have the $ prefix.
    class Operand < Node
      def initialize(name)
        @name = name
      end

      # @return [String]
      attr_reader :name
    end

    # Represents a sequence of other nodes.
    class Sequence < Node
      def initialize(items=[])
        @items = items
      end
      
      # @return [<Node>]
      attr_reader :items

      def walk(variant, &blk)
        items.each do |item|
          item.walk(variant, &blk)
        end
      end
    end

    # Represents a node whose contents changes based on the selected variant.
    class Variant < Node
      def initialize(variants=[])
        @variants = variants
      end

      # @return [<Node>]
      attr_reader :variants

      def walk(variant, &blk)
        if variant
          variants[variant]&.walk(variant, &blk)
        else
          variants.each do |v|
            v.walk(variant, &blk)
          end
        end
      end
    end
  
    # @param format [String]
    # @return [Node]
    def self.parse(format)
      # TODO: nested variants seem to be OK. I am in hell
      # See https://github.com/llvm/llvm-project/blob/1be98277547d3a9b9966f055c8e4939390ac4697/llvm/utils/TableGen/Common/CodeGenInstruction.cpp#L535
      # CodeGenInstruction::FlattenAsmStringVariants

      # Break out the things we care about into separate items in the list:
      #   - Variant characters: {|}
      #   - Operands: $abc
      tokens = format.split(/([\{\|\}]|\$[a-zA-Z0-9_]+)/)

      top_sequence = Sequence.new
      current_sequence = top_sequence
      current_variant = nil

      until tokens.empty?
      token = tokens.shift
        case token
        when '{'
          raise MalformedError, "nested variants are not allowed: #{format}" if current_variant
          current_variant = Variant.new
          current_sequence.items << current_variant
          current_sequence = Sequence.new
          current_variant.variants << current_sequence
        when '}'
          raise MalformedError, "mismatched variant close: #{format}" unless current_variant
          current_variant = nil
          current_sequence = top_sequence
        when '|'
          raise MalformedError, "variant delimiter outside of variant: #{format}" unless current_variant
          current_sequence = Sequence.new
          current_variant.variants << current_sequence
        when /^\$([a-zA-Z0-9_]+)$/
          current_sequence.items << Operand.new($1)
        else          
          current_sequence.items << Text.new(token) unless token.empty?
        end
      end

      top_sequence
    end

    class MalformedError < StandardError
    end
  end
end
