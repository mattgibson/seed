When(/^I (?:visit|am on) the (.*) page$/) do |page_name|
  visit path_to page_name
end

Then(/^show me a screenshot/) do
  screenshot_and_open_image
end

Then(/^show me the page/) do
  save_and_open_page
end
