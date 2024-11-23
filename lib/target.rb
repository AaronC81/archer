require_relative 'target/register'
require_relative 'target/register_class'
require_relative 'target/instruction'
require_relative 'target/explodable_operand_type'
require_relative 'supp'

class Target
  def initialize(name, dump, supp)
    @name = name
    @title = supp.title
    @subtitle = supp.subtitle

    @documentation_provider = supp.documentation_provider

    @registers = dump.definitions(of: :Register)
      .map { |d| Register.new(d) }
      .map { |reg| [reg.name, reg] }
      .to_h

    @register_classes = dump.definitions(of: :RegisterClass)
      .map { |d| RegisterClass.new(d) }
      .map { |regc| [regc.name, regc] }
      .to_h
    @register_classes.each { |_, c| c.resolve_members(self) }

    @operand_types = supp.operand_types
      .map { |ty| [ty.llvm_name, ty] }
      .to_h
    @operand_types['unknown!'] = SupplementaryData::OperandType.new_unknown

    @operand_type_families = supp.operand_type_families
      .map { |fam| [fam.name, fam] }
      .to_h

    @explodable_operand_types = supp.explode_operand_types
      .map do |ty|
        record = dump.fetch(ty.llvm_name)
        inner_operands = record.fetch(:MIOperandInfo)
          .to_array
          .map { |item| [item.name, fetch_operand_type(item.value)] }
        
        [ty.llvm_name, ExplodableOperandType.new(inner_operands, ty.format)]
      end
      .to_h

    @instructions = dump.definitions(of: :Instruction)
      .reject { |d| d.fetch_bool(:isPseudo) } # Reject early, so we don't get "unknown operand types" warnings for useless pseudo stuff
      .reject { |d| d.has_superclass?(:PseudoI) } # Another way of implementing pseudoinstructions, done by x86
      .reject { |d| d.fetch_bool(:isCodeGenOnly) }
      .map do |d|
        begin
          Instruction.new(d, self)
        rescue AssemblyFormatParser::MalformedError => e
          LoadLogger.warn "Unable to parse assembly string for instruction: #{e}"
          nil
        end
      end
      .compact
      .map { |i| [i.name, i] }
      .to_h

    # O(n^2), ouch
    instructions.each do |_, ins|
      supp.instruction_fixups.each do |fixup|
        ins.apply_fixup(fixup)
      end
    end

    @assembly_variants = supp.assembly_variants

    @predicates = supp.predicates
      .map { |pred| [pred.llvm_name, pred] }
      .to_h

    # Check for predicates we don't understand
    unknown_predicates = Set.new
    instructions.each do |_, ins|
      ins.predicates.each do |pred|
        if !predicates.has_key?(pred) && !unknown_predicates.include?(pred)
          LoadLogger.warn "Unknown predicate `#{pred}` (first seen on instruction #{ins.name})"
          unknown_predicates << pred
        end
      end
    end
  end

  attr_reader :name
  attr_reader :registers
  attr_reader :register_classes

  # A friendly title to use for this architecture, which may not match the LLVM `#name`.
  # @return [String]
  attr_reader :title

  # An optional subtitle further describing the architecture.
  # @return [String, nil]
  attr_reader :subtitle

  # @return [{ String => SupplementaryData::OperandType }]
  attr_reader :operand_types

  # @return [{ String => SupplementaryData::OperandTypeFamily }]
  attr_reader :operand_type_families

  # @return [{ Symbol => ExplodableOperandType }]
  attr_reader :explodable_operand_types

  # @return [{ String => Instruction }]
  attr_reader :instructions

  # @return [<String>]
  attr_reader :assembly_variants

  # @return [{ Symbol => SupplementaryData::Predicate }]
  attr_reader :predicates

  # @return [Documentation::Provider]
  attr_reader :documentation_provider

  # @return [LoadLogger] The logger from loading this target. Should be assigned later.
  attr_accessor :logger

  def fetch_register(name)
    registers.fetch(name.to_sym)
  end

  def fetch_operand_type(name)
    unless operand_types.has_key?(name)
      LoadLogger.warn "Unknown operand type `#{name}`"
      operand_types[name] = operand_types['unknown!']
    end
    
    operand_types[name]
  end
end
