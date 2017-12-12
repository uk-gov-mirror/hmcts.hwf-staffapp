require 'rails_helper'
module HwfCalculatorEngine
  RSpec.describe TotalSavingsSubCalculationService do
    subject(:service) { described_class }
    describe '#call' do
      shared_examples 'savings limited to' do |age:, fee:, limit:|
        next_to_limit = limit - 1
        context "age: #{age}, fee: #{fee}" do
          it "states help is available when total_savings: 0" do
            expect(service.call(date_of_birth: (age.years.ago - 1.day).to_date, fee: fee, total_savings: 0)).to have_attributes help_available?: true, help_not_available?: false, messages: a_collection_including(a_hash_including(key: :likely, source: :total_savings))
          end

          it "states help is available when total_savings: 1" do
            expect(service.call(date_of_birth: (age.years.ago - 1.day).to_date, fee: fee, total_savings: 1)).to have_attributes help_available?: true, help_not_available?: false, messages: a_collection_including(a_hash_including(key: :likely, source: :total_savings))
          end

          it "states help is available when total_savings: #{next_to_limit}" do
            expect(service.call(date_of_birth: (age.years.ago - 1.day).to_date, fee: fee, total_savings: next_to_limit)).to have_attributes help_available?: true, help_not_available?: false, messages: a_collection_including(a_hash_including(key: :likely, source: :total_savings))
          end

          it "states help is not available when total_savings: #{limit}" do
            expect(service.call(date_of_birth: (age.years.ago - 1.day).to_date, fee: fee, total_savings: limit)).to have_attributes help_available?: false, help_not_available?: true, messages: a_collection_including(a_hash_including(key: :unlikely, source: :total_savings))
          end

          it "states help is not available when total_savings: #{limit + 1}" do
            expect(service.call(date_of_birth: (age.years.ago - 1.day).to_date, fee: fee, total_savings: limit + 1)).to have_attributes help_available?: false, help_not_available?: true, messages: a_collection_including(a_hash_including(key: :unlikely, source: :total_savings))
          end

          it "states help is not available when total_savings: #{limit + 100000}" do
            expect(service.call(date_of_birth: (age.years.ago - 1.day).to_date, fee: fee, total_savings: limit + 100000)).to have_attributes help_available?: false, help_not_available?: true, messages: a_collection_including(a_hash_including(key: :unlikely, source: :total_savings))
          end
        end
      end
      [1,60].each do |age|
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
        [61, 62, 99].each do |age|
          include_examples 'savings limited to', age: age, fee: 1, limit: 16000
          include_examples 'savings limited to', age: age, fee: 10, limit: 16000
          include_examples 'savings limited to', age: age, fee: 100, limit: 16000
          include_examples 'savings limited to', age: age, fee: 1000, limit: 16000
          include_examples 'savings limited to', age: age, fee: 1000000000000, limit: 16000
        end
      end

      it 'throws :invalid_inputs if not valid' do
        expect { service.call(date_of_birth: nil, fee: 100, total_savings: 1000) }.to throw_symbol(:invalid_inputs)
      end

      it 'throws :invalid_inputs with an instance that is invalid' do
        result = catch(:invalid_inputs) do
          service.call(date_of_birth: nil, fee: 100, total_savings: 1000)
        end
        expect(result).to be_a(described_class).and(an_object_having_attributes valid?: false)
      end
    end

    describe '#help_not_available?' do

    end

    describe '#help_available?' do

    end

    describe '#messages' do

    end

    describe '#valid?' do
      it 'is true when all inputs required are present and correct type' do
        instance = service.new(date_of_birth: 20.years.ago.to_date, fee: 1000, total_savings: 100)
        expect(instance.valid?).to be true
      end

      it 'is false when all inputs required are present but one is of incorrect type' do
        instance = service.new(date_of_birth: "31 December 2017", fee: 1000, total_savings: 100)
        expect(instance.valid?).to be false
      end

      it 'is false when all inputs required are present but one is nil' do
        instance = service.new(date_of_birth: nil, fee: 1000, total_savings: 100)
        expect(instance.valid?).to be false
      end

      it 'is false when one input is missing' do
        instance = service.new(fee: 1000, total_savings: 100)
        expect(instance.valid?).to be false
      end

      it 'is false when all inputs are missing' do
        instance = service.new({})
        expect(instance.valid?).to be false
      end
    end
  end

end