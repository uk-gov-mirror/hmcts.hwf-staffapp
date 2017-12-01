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
  else
    rest_response = RestClient.post "#{calculator_url}/calculation", data.to_json, calculator_api_default_headers
    self.response = OpenStruct.new(body: rest_response.body, status: rest_response.code, headers: rest_response.headers)
  end
end