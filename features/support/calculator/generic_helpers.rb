# rubocop:disable Style/TrivialAccessors
def test_request=(request)
  @test_request = request
end

def test_request
  @test_request
end

def calculator_system_config
  @calculator_system_config ||= OpenStruct.new(fee_bands: [])
end

def calculator_url
  return ENV.fetch('CALCULATOR_URL') if ENV.key('CALCULATOR_URL')
  server = Capybara.current_session.server
  "http://#{server.host}:#{server.port}/calculator"
end

def calculator_api_default_headers
  { accept: :json, content_type: :json }
end