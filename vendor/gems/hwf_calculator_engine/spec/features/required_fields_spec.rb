require 'rails_helper'

RSpec.feature 'Test for required fields', type: :request do
  let(:calculator_response) { JSON.parse(response.body) }

  it 'returns empty inputs' do
    calculate({ marital_status: 'sharing_income'})
    expect(calculator_response.dig('calculation', 'fields_required')).to contain_exactly('fee', 'date_of_birth', 'total_savings', 'benefits_received', 'number_of_children', 'total_income')
  end
end