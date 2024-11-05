require_relative 'value'

module TableGen
  # A definition from TableGen.
  #
  # In TableGen, definitions are a kind of _record_, which is a concrete instantiation of a _class_
  # (the other kind of record).
  class Definition
    def initialize(hash)
      @hash = hash
        .map { |k, v| [k, Value.from_json(v)] }
        .to_h
    end

    # Get a field from this definition, or nil if it isn't set.
    def [](field)
      @hash[field.to_s]
    end

    # Get a field from this definition, or throw an exception if it isn't set.
    def fetch(field)
      @hash.fetch(field.to_s)
    end

    # Get a `bit` field from this definition, and convert it to a boolean.
    # Throw an exception if the field does not exist.
    # @param field [Symbol] Name of the field.
    # @param default [Boolean] Default if the field is unset (`?`).
    # @return [Boolean]
    def fetch_bool(field, default: false)
      value = fetch(field)

      case value
      when 1
        true
      when 0
        false
      when TrueClass, FalseClass # Don't think this happens, but just in case
        value
      when nil
        default
      else
        raise "unexpected value for boolean field `#{field}`: #{value}"
      end
    end

    # The name of this definition.
    # @return [Symbol]
    def name
      fetch('!name').to_sym
    end

    # The list of superclasses of this definition.
    # @return [<Symbol>]
    def superclasses
      fetch('!superclasses').map(&:to_sym)
    end

    # Whether this definition has the given superclass.
    # @param [Symbol] sup
    # @return [Boolean]
    def has_superclass?(sup)
      superclasses.include?(sup.to_sym)
    end
    alias is_subclass? has_superclass?
  end
end
