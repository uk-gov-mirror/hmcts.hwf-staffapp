module HwfCalculatorEngineTest
  module Calculation
    def calculator_api_default_headers
      { accept: 'application/json', content_type: 'application/json'}
    end

    def calculator_url
      "http://localhost:1111/api/calculator"
    end

    attr_accessor :response

    def calculate(test_request)
      data = { calculation: { inputs: test_request } }
      env = calculator_api_default_headers.inject({}) do |result, (key, value)|
        key = key.to_s.upcase
        key = "HTTP_#{key}" unless key == 'CONTENT_TYPE'
        result[key] = value
        result
      end
      post "/api/calculator/calculation", data.to_json, env
    end
  end
end
RSpec.configure do |config|
  config.include HwfCalculatorEngineTest::Calculation, type: :request
end