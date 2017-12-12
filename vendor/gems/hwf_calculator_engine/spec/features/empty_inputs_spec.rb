require 'rails_helper'

RSpec.feature 'Test for empty inputs', type: :request do
  let(:calculator_response) { JSON.parse(response.body) }

  it 'returns empty inputs' do
    calculate({})
    expect(calculator_response.dig('calculation', 'inputs')).to be_empty
  end
end