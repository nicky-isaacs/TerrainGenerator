When /^I visit the new generator page$/ do
  visit ui_url '/generator/new'
end

When /^I press "(.*?)"$/ do |button|
  click_button button
end

Then /^I should be on the generator creation page/ do
  expect(page).to have_content "Create component"
end