module TableGen
  # An abstract class for values from TableGen.
  #
  # For values which have a direct Ruby equivalent, like integers or strings, subclasses of `Value`
  # aren't used.
  # `Value` is used for more complex conversions like DAGs.
  class Value
    def initialize
      raise 'abstract'
    end

    # Convert a part of a TableGen JSON dump into the appropriate value.
    # This may be a subclass of `Value`, or a Ruby primitive type, depending on the value.
    def self.from_json(json)
      case json
      when Integer, String, TrueClass, FalseClass, NilClass
        json
      when Array
        json.map { |el| Value.from_json(el) }
      when Hash
        case json['kind']
        when 'dag'
          Dag.new(json)
        when 'def'
          # Defs become symbols instead of strings, to differentiate them
          json['def'].to_sym
        when 'complex', 'varbit', 'var'
          Complex.new(json)
        else
          raise "unknown complex TableGen value: #{json}"
        end
      else
        raise "unknown object for value conversion: #{json}"
      end
    end
  end
end

require_relative 'value/dag'
require_relative 'value/complex'
