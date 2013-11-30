#encoding: utf-8
 

When /^I visit the login screen$/ do
  visit ui_url '/users/sign_in'
end

And /^I enter username "(.*?)"$/ do |username|
  fill_in("#user_email", :with => username)
end

And /^I enter password "(.*?)"$/ do |password|
  fill_in("#user_password", :with => password)
end

Then /^I should be logged in$/ do
  expect(page).to have_content 'logout'
end
