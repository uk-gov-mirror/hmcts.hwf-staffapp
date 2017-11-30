When(/^I request a calculation$/) do
  use_rack_test = ENV.fetch('USE_RACK_TEST', 'false') == 'true'
  data = { calculation: { inputs: test_request.to_h } }
  if use_rack_test
    env = calculator_api_default_headers.inject({}) do |result, (key, value)|
      key = key.to_s.upcase
      key = "HTTP_#{key}" unless key == 'CONTENT_TYPE'
      result[key] = value
      result
    end
    self.response = post "/api/calculator/calculation", data.to_json, env
    tmp = 1
  else
    self.response = RestClient.post "#{calculator_url}/calculation", data.to_json, calculator_api_default_headers
    if (200.299).include?(response.status)
      self.calculator_response = ::Test::Calculator::Response.parse JSON.parse(response.body)
    end
  end
end