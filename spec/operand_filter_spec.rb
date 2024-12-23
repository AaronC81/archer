require 'capybara/dsl'
require_relative 'ui/filters'

feature "Operand filtering" do
  it "works for 'none' operands" do
    visit '/target/X86'

    no_input_operands_filter.set(true)
    memory_store_filter.set(true)

    expect(page).to have_content 'pushaw'
  end

  it "works for specific operand types" do
    visit '/target/TriCore'

    input_operand_filter("Data register").set(true)
    output_operand_filter("Address register").set(true)

    expect(page).to have_content 'mov.a'
  end
end
