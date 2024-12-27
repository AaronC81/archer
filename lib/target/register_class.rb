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
      @members = expand_members_dag(@members)
        .map { |member| resolve_member(member, target) }
        .compact
    end

    # @return [<Symbol>]
    private def expand_members_dag(dag)
      return dag unless dag.is_a?(TableGen::Value::Dag)

      case dag.operator
      when :add
        dag.arguments.flat_map { |arg| expand_members_dag(arg.value) }

      when :sequence
        pattern, first, last = dag.to_array.map(&:value)
        (first...last).map { |i| (pattern % i).to_sym }

      when :and, :sub, :trunc, :interleave
        LoadLogger.warn "`#{name}` register class uses unsupported `#{dag.operator}` DAG operator to collect members"
        []

      else
        raise "unknown register DAG operator #{dag.operator}"
      end
    end

    private def resolve_member(member_name, target)
      target.registers[member_name] || target.register_classes[member_name] || (
        LoadLogger.warn "`#{name}` register class has unresolvable register member `#{member_name}`"
        nil
      )
    end
  end
end
