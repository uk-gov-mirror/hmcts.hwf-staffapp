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
  ENV.fetch('CALCULATOR_URL')
end

def calculator_api_default_headers
  { accept: :json, content_type: :json }
end