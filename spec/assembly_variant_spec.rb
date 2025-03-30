require 'capybara/dsl'
require_relative 'ui/filters'

feature "Assembly variant selector" do
  it "is not shown on targets with only one variant" do
    visit '/target/TriCore'
    expect(page).not_to have_selector '#assembly-variant-selector'
  end

  it "toggles between mnemonics and operand orderings" do
    visit '/target/X86#MOV8mr'

    # Defaults to AT&T
    expect(page).to have_text 'movb src, dst'

    # Swap to Intel
    select_assembly_variant 'Intel'
    expect(page).to have_text 'mov dst, src'

    # Back to AT&T
    select_assembly_variant 'AT&T'
    expect(page).to have_text 'movb src, dst'
  end
end
