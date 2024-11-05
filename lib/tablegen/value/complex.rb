module TableGen
  class Value
    # A complex suffixed value.
    # I haven't needed these yet, so they're not translated comprehensively.
    class Complex
      def initialize(value)
        @value = value
      end
      attr_reader :value
    end
  end
end
