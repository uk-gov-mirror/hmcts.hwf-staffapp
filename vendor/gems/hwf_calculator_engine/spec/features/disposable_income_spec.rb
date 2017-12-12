require 'rails_helper'

RSpec.feature 'Test for Disposable Capital', type: :request do
  let(:calculator_response) { JSON.parse(response.body) }
  shared_examples 'perform calculation' do |age:, court_fee:, capital:, likelyhood:|
    it "is #{likelyhood} for age #{age}, court fee #{court_fee}, capital #{capital}" do
      calculate date_of_birth: (age.years.ago - 2.days).to_date,
                court_fee: court_fee.to_f,
                total_savings: capital.to_f
      expect(calculator_response['likelyhood']).to eql likelyhood
    end

    it 'adds to the previous answers' do
      calculate date_of_birth: (age.years.ago - 2.days).to_date,
                court_fee: court_fee.to_f,
                total_savings: capital.to_f
      expect(calculator_response['previous_answers']).to include total_savings: capital.to_f
    end
  end

  include_examples 'perform calculation', age: 59, court_fee: 100, capital: 2999, likelyhood: 'likely'

end