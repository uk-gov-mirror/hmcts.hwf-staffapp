Given(/^I am a valid api user$/) do
  self.test_request = OpenStruct.new
end

And(/^I am single$/) do
  test_request.marital_status = 'single'
end

And(/^I am married or sharing an income$/) do
  test_request.marital_status = 'sharing_income'
end

And(/^I am under (\d+) years old$/) do |years|
  test_request.date_of_birth = (years.to_i.years.ago - 1.day).to_date
end

# rubocop:disable LineLength
And(/^fee band is up to and including £((?:\d|\.)*) with a disposable capital less than £((?:\d|\.)*)$/) do |fee_band, capital|
  calculator_system_config.fee_bands << { 0..(fee_band.to_f) => capital.to_f }
end
# rubocop:enable LineLength

Given(/^the court or tribunal fee is (.*)$/) do |fee|
  test_request.fee = fee.to_f
end

And(/^the savings and investment amount is ((?:\d|\.)*)$/) do |total_savings|
  test_request.total_savings = total_savings.to_f
end