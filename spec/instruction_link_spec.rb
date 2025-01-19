require 'capybara/dsl'
require_relative 'ui/filters'

feature 'Instruction linking' do
  it 'displays links on each instruction' do
    visit '/target/TriCore'

    # Filter to just mov.a
    input_operand_filter("Data register").set(true)
    output_operand_filter("Address register").set(true)

    expect(page).to have_link('MOV_A_rr', href: '#MOV_A_rr')

    # Navigate there
    click_on 'MOV_A_rr'

    # Check page has updated
    expect(page.current_url).to end_with('#MOV_A_rr')
    expect(page).to have_content 'mov.a'
    expect(page).to have_content 'Currently showing one specific instruction'
  end

  it 'works when the page is visited directly' do
    visit '/target/TriCore#MOV_A_rr'
    
    expect(page.current_url).to end_with('#MOV_A_rr')
    expect(page).to have_content 'mov.a'
    expect(page).to have_content 'Currently showing one specific instruction'
  end
end
