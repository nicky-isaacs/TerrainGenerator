When /I visit the preview page$/ do
  visit ui_url '/generator/preview'
end

Then /^I should see a 3D viewer$/ do
  expect(page).to have_selector 'canvas'
end