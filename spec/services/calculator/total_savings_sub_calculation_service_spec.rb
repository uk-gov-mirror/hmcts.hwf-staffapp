require 'rails_helper'
module Calculator
  RSpec.describe TotalSavingsSubCalculationService do
    subject(:service) { described_class }
    describe '#call' do
      shared_examples 'savings limited to' do |age:, fee:, limit:|
        mid_way = (limit / 2).to_i
        next_to_limit = limit - 1
        context "age: #{age}, fee: #{fee}" do
          it "states help is available when total_savings: 0" do
            expect(service.call(date_of_birth: (age.years.ago - 1.day).to_date, fee: fee, total_savings: 0)).to have_attributes help_available?: true, help_not_available?: false
          end
          it "states help is available when total_savings: 1" do
            expect(service.call(date_of_birth: (age.years.ago - 1.day).to_date, fee: fee, total_savings: 1)).to have_attributes help_available?: true, help_not_available?: false
          end
          it "states help is available when total_savings: #{next_to_limit}" do
            expect(service.call(date_of_birth: (age.years.ago - 1.day).to_date, fee: fee, total_savings: next_to_limit)).to have_attributes help_available?: true, help_not_available?: false
          end
          it "states help is not available when total_savings: #{limit}" do
            expect(service.call(date_of_birth: (age.years.ago - 1.day).to_date, fee: fee, total_savings: limit)).to have_attributes help_available?: false, help_not_available?: true
          end
          it "states help is not available when total_savings: #{limit + 1}" do
            expect(service.call(date_of_birth: (age.years.ago - 1.day).to_date, fee: fee, total_savings: limit + 1)).to have_attributes help_available?: false, help_not_available?: true
          end
          it "states help is not available when total_savings: #{limit + 100000}" do
            expect(service.call(date_of_birth: (age.years.ago - 1.day).to_date, fee: fee, total_savings: limit + 100000)).to have_attributes help_available?: false, help_not_available?: true
          end
        end
      end
      [1,60,61].each do |age|
        context "age: #{age}" do
          include_examples 'savings limited to', age: age, fee: 1, limit: 3000
          include_examples 'savings limited to', age: age, fee: 500, limit: 3000
          include_examples 'savings limited to', age: age, fee: 999, limit: 3000
          include_examples 'savings limited to', age: age, fee: 1000, limit: 3000
          include_examples 'savings limited to', age: age, fee: 1001, limit: 4000
          include_examples 'savings limited to', age: age, fee: 1334, limit: 4000
          include_examples 'savings limited to', age: age, fee: 1335, limit: 4000
          include_examples 'savings limited to', age: age, fee: 1336, limit: 5000
          include_examples 'savings limited to', age: age, fee: 1500, limit: 5000
          include_examples 'savings limited to', age: age, fee: 1664, limit: 5000
          include_examples 'savings limited to', age: age, fee: 1665, limit: 5000
          include_examples 'savings limited to', age: age, fee: 1666, limit: 6000
          include_examples 'savings limited to', age: age, fee: 1800, limit: 6000
          include_examples 'savings limited to', age: age, fee: 1999, limit: 6000
          include_examples 'savings limited to', age: age, fee: 2000, limit: 6000
          include_examples 'savings limited to', age: age, fee: 2001, limit: 7000
          include_examples 'savings limited to', age: age, fee: 2150, limit: 7000
          include_examples 'savings limited to', age: age, fee: 2329, limit: 7000
          include_examples 'savings limited to', age: age, fee: 2330, limit: 7000
          include_examples 'savings limited to', age: age, fee: 2331, limit: 8000
          include_examples 'savings limited to', age: age, fee: 3000, limit: 8000
          include_examples 'savings limited to', age: age, fee: 3999, limit: 8000
          include_examples 'savings limited to', age: age, fee: 4000, limit: 8000
          include_examples 'savings limited to', age: age, fee: 4001, limit: 10000
          include_examples 'savings limited to', age: age, fee: 4500, limit: 10000
          include_examples 'savings limited to', age: age, fee: 4999, limit: 10000
          include_examples 'savings limited to', age: age, fee: 5000, limit: 10000
          include_examples 'savings limited to', age: age, fee: 5001, limit: 12000
          include_examples 'savings limited to', age: age, fee: 5500, limit: 12000
          include_examples 'savings limited to', age: age, fee: 5999, limit: 12000
          include_examples 'savings limited to', age: age, fee: 6000, limit: 12000
          include_examples 'savings limited to', age: age, fee: 6001, limit: 14000
          include_examples 'savings limited to', age: age, fee: 6500, limit: 14000
          include_examples 'savings limited to', age: age, fee: 6999, limit: 14000
          include_examples 'savings limited to', age: age, fee: 7000, limit: 14000
          include_examples 'savings limited to', age: age, fee: 7001, limit: 16000
          include_examples 'savings limited to', age: age, fee: 10000, limit: 16000
          include_examples 'savings limited to', age: age, fee: 1000000000000, limit: 16000
        end
        [62, 99].each do |age|
          include_examples 'savings limited to', age: age, fee: 1, limit: 16000
          include_examples 'savings limited to', age: age, fee: 10, limit: 16000
          include_examples 'savings limited to', age: age, fee: 100, limit: 16000
          include_examples 'savings limited to', age: age, fee: 1000, limit: 16000
          include_examples 'savings limited to', age: age, fee: 1000000000000, limit: 16000
        end
      end
    end

    describe '#help_not_available?' do

    end

    describe '#help_available?' do

    end

    describe '#failure_reasons' do

    end
  end

end