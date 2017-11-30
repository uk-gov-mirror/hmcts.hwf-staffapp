When(/^I request a calculation$/) do
  use_rack_test = ENV.fetch('USE_RACK_TEST', 'false') == 'true'
  if use_rack_test
    self.response = post "/calculator/calculation", test_request.to_h.to_json, calculator_api_default_headers
    tmp = 1
  else
    self.response = RestClient.post "#{calculator_url}/calculation", test_request.to_h.to_json, calculator_api_default_headers
    if (200.299).include?(response.status)
      self.calculator_response = ::Test::Calculator::Response.parse JSON.parse(response.body)
    end
  end
end