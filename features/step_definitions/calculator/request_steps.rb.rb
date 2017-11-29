When(/^I request a calculation$/) do
  self.response = RestClient.post "#{calculator_url}/calculation", test_request.to_h.to_json, calculator_api_default_headers
  if (200.299).include?(response.status)
    self.calculator_response = ::Test::Calculator::Response.parse JSON.parse(response.body)
  end
end