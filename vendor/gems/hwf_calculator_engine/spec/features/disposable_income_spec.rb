require 'rails_helper'

RSpec.feature 'Test for Disposable Capital', type: :request do
  let(:calculator_response) { JSON.parse(response.body) }
  shared_examples 'likely outcome' do |age:, fee:, capital:|
    it "is likely for age #{age}, court fee #{fee}, capital #{capital}" do
      calculate date_of_birth: (age.years.ago - 2.days).to_date,
                fee: fee.to_f,
                total_savings: capital.to_f
      expect(calculator_response.dig('calculation', 'result')).to include 'should_get_help' => true, 'should_not_get_help' => false
    end

    it 'adds to the inputs' do
      calculate date_of_birth: (age.years.ago - 2.days).to_date,
                fee: fee.to_f,
                total_savings: capital.to_f
      expect(calculator_response.dig('calculation', 'inputs')).to include 'total_savings' => capital.to_f
    end

    it 'adds the messages' do
      calculate date_of_birth: (age.years.ago - 2.days).to_date,
                fee: fee.to_f,
                total_savings: capital.to_f
      expect(calculator_response.dig('calculation', 'result', 'messages')).to include a_hash_including 'key' => 'likely',
                                                                                                       'parameters' => a_hash_including(
                                                                                                                           'date_of_birth' => (age.years.ago - 2.days).to_date.strftime('%Y-%m-%d'),
                                                                                                                           'fee' => fee.to_f,
                                                                                                                           'total_savings' => capital.to_f
                                                                                                       ),
                                                                                                       'source' => 'total_savings'
    end
  end

  include_examples 'likely outcome', age: 59, fee: 100, capital: 2999

end