Given(/^I am a valid api user$/) do
  self.test_request = OpenStruct.new
end

And(/^I am single$/) do
  test_request.marital_status = 'single'
end

And(/^I am married or sharing an income$/) do
  test_request.marital_status = 'sharing_income'
end

Given(/^the court or tribunal fee is (.*)$/) do |fee|
  test_request.fee = fee.to_f
end

And(/^the savings and investment amount is ((?:\d|\.)*)$/) do |total_savings|
  test_request.total_savings = total_savings.to_f
end

And(/^the age is (\d*)$/) do |years|
  test_request.date_of_birth = (years.to_i.years.ago - 1.day).to_date
end