#encoding: utf-8
 

When /^I visit the login screen$/ do
  visit (ui_url '/users/sign_in')
  puts (ui_url '/users/sign_in')
end

And /^I enter username "(.*?)"$/ do |username|
  puts current_url
  page.fill_in("user_email", :with => username)
end

And /^I enter password "(.*?)"$/ do |password|
  page.fill_in("user_password", :with => password)
end

Then /^I should be logged in$/ do
  expect(page).to have_content 'logout'
end

Then /^I should see my generators$/ do
  expect(page.body).to have_content "class=\"generator_wrapper\""
end

When(/^I enter name "(.*?)"$/) do |arg1|
  fill_in('component name', :with => arg1)
end
