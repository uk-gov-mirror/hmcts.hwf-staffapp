module Forms
  module Calculator
    RSpec.describe Calculation do
      subject(:calculation) { described_class.new(calculation_data) }



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


    end
  end
end