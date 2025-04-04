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

  # Generate front-end data describing this target's operand families, predicates, and other factors
  # relevant to filtering.
  # @return [Hash]
  def adapt_details
    {
      name: target.name,
      title: target.title,
      assemblyVariants: target.assembly_variants,

      operandTypeFamilies: target.operand_type_families.map do |_, ty|
        {
          name: ty.name,
          style: ty.colour.css_text_style,
        }
      end,

      predicateFamilies: target.predicates
        .values
        .group_by(&:family)
        .sort_by { |family, _| family == nil ? 0 : 1 } # Put "no family" first
        .map do |family, preds|
          {
            family: family,
            predicates: preds.map do |pred|
              {
                friendlyName: pred.friendly_name,
                important: pred.important?,
              }
            end.uniq,
          }
        end,
    }
  end

  # Generate front-end data describing all instructions available on this target.
  # @return [Array] The list of instructions.
  def adapt_instructions
    target.instructions.values.map do |ins|
      {
        name: ins.name,
        assemblyVariants: target.assembly_variants.length.times.map do |i|
          {
            mnemonic: ins.mnemonic_for_variant(i),
            format: ins.assembly_format_for_variant(i),
            html: ins.assembly_parts_for_variant(i)
              .map do |type, param|
                case type
                when :text
                  param
                when :mnemonic
                  "<b>#{param}</b>"
                when :operand
                  style = operand_type_family_colour(param.operand_type.family)
                  "<mark style=\"#{style}\">#{param.name}</mark>"
                else
                  raise 'unknown assembly part'
                end
              end
              .join,
          }
        end,

        input: {
          memory: ins.may_load?,
          implicit: ins.implicitly_read_registers.map(&:name).map(&:to_s),
          operands: adapt_instruction_operand_list(ins.inputs),
        },

        output: {
          memory: ins.may_store?,
          implicit: ins.implicitly_written_registers.map(&:name).map(&:to_s),
          operands: adapt_instruction_operand_list(ins.outputs),
        },

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
