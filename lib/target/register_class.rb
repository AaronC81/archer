class Target
  # A named set of related registers.
  class RegisterClass
    def initialize(defi)
      @name = defi.name

      # To start with, put a DAG in `#members` (violating its expected type.)
      # This is because classes can reference each other; if we try to resolve now, we might not
      # have actually created the other class yet.
      # `#resolve_members` will fix this.
      @members = defi.fetch('MemberList')
    end

    # @return [Symbol] LLVM's internal name for this register class.
    attr_reader :name

    # @return [<Register, RegisterClass>] The concrete registers, or other classes of registers,
    #   which are part of this register class.
    attr_reader :members

    def inspect
      "<#{self.class}: #{name}, #{members}>"
    end    

    # Called once, internally, to fix up member list. Don't call again later!
    def resolve_members(target)
      case @members.operator

      when :add # Plain-old list
        @members = @members.to_array.map { |member| resolve_member(member.value, target) }.compact
        
      when :sequence # (sequence "r%u", 0, 15)
        pattern, first, last = @members.to_array.map(&:value)
        names = (first...last).map { |i| (pattern % i).to_sym }

        @members = names.map { |member| resolve_member(member, target) }.compact

      when :and, :sub # boolean operators?
        puts "WARNING: `#{name}` register class uses unsupported `#{@members.operator}` type"
        @members = []
      
      else
        raise "unknown register DAG operator #{@members.operator}"
      end
    end

    private def resolve_member(member_name, target)
      target.registers[member_name] || target.register_classes[member_name] || (
        puts "WARNING: `#{name}` register class has unresolvable register member `#{member_name}`"
        nil
      )
    end
  end
end
