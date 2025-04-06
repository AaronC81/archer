require 'capybara/dsl'
require_relative 'ui/filters'

feature "Predicate filtering" do
  it "shows and hides based on selected predicates" do
    visit '/target/X86'

    # This is an "x87 FPU" instruction
    # All predicates are selected by default, so this should show
    mnemonic_filter.set 'fabs'
    expect(page).to have_content 'ABS_F' # LLVM name
 
    # Expand predicates
    predicate_header('SIMD/FPU').click

    # Untick that filter - it goes away
    predicate_filter('x87 FPU').set(false)
    expect(page).not_to have_content 'ABS_F'

    # Tick the filter - comes back
    predicate_filter('x87 FPU').set(true)
    expect(page).to have_content 'ABS_F'

    # Untick an irrelevant filter - still there
    predicate_filter('3DNow!').set(false)
    expect(page).to have_content 'ABS_F'
  end
end
