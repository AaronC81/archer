require 'json'

require_relative 'definition'
require_relative 'value'

module TableGen
  # A complete TableGen dump.
  class Dump
    def initialize(hash)
      @hash = hash
        .select { |key, value| value.is_a?(Hash) && !key.start_with?('!') }
        .map { |key, value| [key.to_sym, TableGen::Definition.new(value)] }
        .to_h
    end

    def self.load(file)
      new(JSON.parse(File.read(file)))
    end

    def [](name)
      @hash[name.to_sym]
    end

    def fetch(name)
      @hash.fetch(name.to_sym)
    end

    def definitions(of: nil)
      defs = @hash.values

      if of
        defs.select! { |d| d.has_superclass?(of.to_sym) }
      end

      defs
    end
  end
end
