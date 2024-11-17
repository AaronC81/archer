require_relative 'link'

module Documentation
  # An abstract class which can be subclassed to specify how documentation can be provided for a
  # target.
  class Provider
    # Build and return a documentation link for an instruction.
    # If there isn't any documentation for this instruction, return nil.
    #
    # @param ins [Instruction]
    # @return [Link, nil]
    def documentation_link(ins)
      raise 'abstract'
    end
  end
end
