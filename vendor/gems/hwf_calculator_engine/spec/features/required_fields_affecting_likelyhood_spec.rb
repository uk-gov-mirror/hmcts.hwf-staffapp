require 'rails_helper'

RSpec.feature 'Test for required fields', type: :request do
  let(:calculator_response) { JSON.parse(response.body) }

  it 'returns empty inputs' do
    calculate({ marital_status: 'sharing_income'})
    expect(calculator_response.dig('calculation', 'required_fields_affecting_likelyhood')).to contain_exactly('date_of_birth', 'total_savings', 'benefits_received', 'total_income')
  end
end