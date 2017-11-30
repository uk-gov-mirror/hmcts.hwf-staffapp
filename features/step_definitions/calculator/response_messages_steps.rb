Then(/^the response should have only messages with keys (.*) and (.*)$/) do |message_key1, message_key2|
  expect(calculator_response.messages.map(&:key)).to eql [message_key1, message_key2]
  expect(calculator_response.messages.map(&:parameters)).to all(eq(test_request.to_h))
end

And(/^the response should suggest the likelyhood of getting help as (.*)$/) do |likelyhood|
  expect(calculator_response.likelyhood).to eql likelyhood
end

And(/^the response should contain a savings and investment amount of (.*) in the previous answers$/) do |total_savings|
  expect(calculator_response.previous_answers).to include('total_savings' => total_savings.to_f)
end

And(/^the response should request that the "([^"]*)" question is the next question to be answered$/) do |question|
  expect(calculator_response.next_question).to eql question
end