# rubocop:disable Style/TrivialAccessors
def test_request=(request)
  @test_request = request
end

def test_request
  @test_request
end

def test_user
  @test_user
end

def response=(response)
  @response = response
end

def response
  @response
end

def calculator_response
  ::Test::Calculator::Response.parse(response)
end

def calculator_system_config
  @calculator_system_config ||= OpenStruct.new(fee_bands: [])
end

def calculator_url
  return ENV.fetch('CALCULATOR_URL') if ENV.key('CALCULATOR_URL')
  server = Capybara.current_session.server
  "http://#{server.host}:#{server.port}/api/calculator"
end

def calculator_api_default_headers
  { accept: 'application/json', content_type: 'application/json' }
end