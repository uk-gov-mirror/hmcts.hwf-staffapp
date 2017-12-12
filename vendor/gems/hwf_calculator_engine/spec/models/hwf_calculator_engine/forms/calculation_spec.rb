require 'rails_helper'
module HwfCalculatorEngine
  module Forms
    RSpec.describe Calculation do
      describe '#to_h' do
        it 'is empty with empty inputs' do
          form = described_class.new({})
          expect(form.to_h).to be_empty
        end

        it 'is only has one key when only 1 key is given in the output' do
          form = described_class.new({ fee: 10 })
          expect(form.to_h.keys).to contain_exactly(:fee)
        end

        it 'is only has two keys when only 2 keys are given in the output' do
          form = described_class.new({ fee: 10, total_savings: 1000})
          expect(form.to_h.keys).to contain_exactly(:fee, :total_savings)
        end

      end

      describe '#date_of_birth=' do
        it 'persists as a date' do
          form = described_class.new({})
          form.date_of_birth = '1999-12-27'
          expect(form.date_of_birth).to eql Date.parse('27 December 1999')
        end
      end

      describe '#date_of_birth via initialize' do
        it 'persists as a date' do
          form = described_class.new({ date_of_birth: '1999-12-27'})
          expect(form.date_of_birth).to eql Date.parse('27 December 1999')
        end
      end

      describe '#fee=' do
        it 'persists as a float' do
          form = described_class.new({})
          form.fee = '10'
          expect(form.fee).to eql 10.0
        end
      end

      describe '#fee= via initialize' do
        it 'persists as a float' do
          form = described_class.new(fee: '10')
          expect(form.fee).to eql 10.0
        end
      end

      describe '#total_savings=' do
        it 'persists as a float' do
          form = described_class.new({})
          form.total_savings = '10000'
          expect(form.total_savings).to eql 10000.0
        end
      end

      describe '#total_savings= via initialize' do
        it 'persists as a float' do
          form = described_class.new(total_savings: '10000')
          expect(form.total_savings).to eql 10000.0
        end
      end

      describe '#marital_status=' do
        it 'persists as a float' do
          form = described_class.new({})
          form.marital_status = 'sharing_income'
          expect(form.marital_status).to eql 'sharing_income'
        end
      end

      describe '#marital_status= via initialize' do
        it 'persists as a float' do
          form = described_class.new(marital_status: 'sharing_income')
          expect(form.marital_status).to eql 'sharing_income'
        end
      end

      context 'validation' do
        it 'should have validation stuff - @TODO'
      end

    end
  end
end