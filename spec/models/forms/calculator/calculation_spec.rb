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
    end
  end
end