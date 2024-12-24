# Converts the target data model into hashes, which are used as JSON to render the front-end pages.
# 
# This is therefore quite closely coupled to the front-end JavaScript.
class Adapter
  # @param target [Target] The target to generate information for.
  def initialize(target)
    @target = target
  end

  # @return [Target]
  attr_reader :target

  # Generate front-end data describing all instructions available on this target.
  # @return [Array] The list of instructions.
  def adapt_instructions
    target.instructions.values.map do |ins|
      {
        name: ins.name,
        assemblyVariants: target.assembly_variants.length.times.map do |i|
          {
            format: ins.assembly_format_for_variant(i),
            html: ins.assembly_parts_for_variant(i)
              .map do |type, param|
                case type
                when :text
                  param
                when :operand
                  style = operand_type_family_colour(param.operand_type.family)
                  "<mark style=\"#{style}\">#{param.name}</mark>"
                else
                  raise 'unknown assembly part'
                end
              end
              .join
          }
        end,

        mayStore: ins.may_store?,
        mayLoad: ins.may_load?,

        inputs: adapt_instruction_operand_list(ins.inputs),
        outputs: adapt_instruction_operand_list(ins.outputs),

        implicitInputs: ins.implicitly_read_registers.map(&:name).map(&:to_s),
        implicitOutputs: ins.implicitly_written_registers.map(&:name).map(&:to_s),

        predicates:
          ins.predicates
            .map { |pred| @target.predicates[pred] }
            .compact
            .uniq(&:friendly_name) # Predicates are allowed to share friendly names
            .sort_by { |pred| pred.important? ? 0 : 1 }
            .map do |pred|
              {
                friendly_name: pred.friendly_name,
                important: pred.important,
              }
            end,

        documentation: 
          if ins.documentation
            {
              text: ins.documentation.text,
              url: ins.documentation.url,
            }
          else
            nil
          end,
      }
    end
  end

  private def adapt_instruction_operand_list(ops)
    ops.map do |op|
      {
        name: op.name,
        operandType: op.operand_type.friendly_name,
        operandTypeFamily: op.operand_type.family,
        operandTypeFamilyStyle: operand_type_family_colour(op.operand_type.family),
      }
    end
  end

  private def operand_type_family_colour(family_name)
    target.operand_type_families[family_name]&.colour&.css_text_style
  end
end
