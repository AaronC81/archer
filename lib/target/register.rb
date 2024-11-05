class Target
  # A specific register on the target.
  class Register
    def initialize(defi)
      @name = defi.name
    end

    # @return [Symbol] LLVM's internal name for this instruction.
    attr_reader :name

    # TODO: registers can contain other registers, would be good to represent this somehow

    def inspect
      "<#{self.class}: #{name}>"
    end
  end
end
