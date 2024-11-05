module TableGen
  class Value
    # TableGen's representation of a directed acyclic graph.
    #
    # TableGen models these as nested arrays, each with an "operator" and then a (possibly empty)
    # set of arguments.
    #
    # For example:
    # 
    #    (add (mul 2, 3), (sub 10, 4))
    #
    # Represents:
    #
    # ```
    #      add
    #    /     \
    #  mul     sub
    #  / \     / \
    # 2   3   10  4
    # ```
    #
    # Each argument can have a name and/or a value.
    class Dag
      Argument = Struct.new('Argument', :name, :value)

      def initialize(hash)
        raise 'not a dag' unless hash['kind'] == 'dag'

        @operator = Value.from_json(hash['operator'])
        @arguments = hash['args'].map do |value, name|
          Argument.new(name, Value.from_json(value))
        end
      end

      # @return [Symbol] The operator in the list.
      attr_reader :operator

      # @return [<Argument>] The arguments after the operator.
      attr_reader :arguments

      # Assert that this DAG represents a flat array, and returns its arguments.
      # @raise [ArgumentError] If the DAG is not a flat array.
      # @return [<Argument>]
      def to_array
        raise ArgumentError, "DAG is not a flat array" unless is_array?
        arguments
      end

      # Whether this DAG represents a flat array of its arguments, without any other DAGs nested
      # inside, like:
      #
      # ```
      #       foo
      #  .-----+-----.
      #  |  |  |  |  |
      #  1  2  3  4  5
      # ```
      def is_array?
        arguments.all? { |arg| !arg.value.is_a?(Dag) }
      end
    end
  end
end
