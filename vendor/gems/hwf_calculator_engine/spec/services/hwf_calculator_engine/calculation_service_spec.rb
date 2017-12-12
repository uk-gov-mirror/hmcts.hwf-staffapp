require 'rails_helper'
module HwfCalculatorEngine
  RSpec.describe CalculationService do
    subject(:service) { described_class }

    shared_context 'fake calculators' do
      let(:calculator_1_class) { class_spy(BaseSubCalculationService, 'Calculator 1 class') }
      let(:calculator_2_class) { class_spy(BaseSubCalculationService, 'Calculator 2 class') }
      let(:calculator_3_class) { class_spy(BaseSubCalculationService, 'Calculator 3 class') }

      let(:calculator_1) do
        instance_double(BaseSubCalculationService, 'Calculator 1', help_not_available?: false, help_available?: false, valid?: true)
      end

      let(:calculator_2) do
        instance_double(BaseSubCalculationService, 'Calculator 2', help_not_available?: false, help_available?: false, valid?: true)
      end

      let(:calculator_3) do
        instance_double(BaseSubCalculationService, 'Calculator 3', help_not_available?: false, help_available?: false, valid?: true)
      end

      let(:calculators) { [calculator_1_class, calculator_2_class, calculator_3_class] }
    end

    describe '#call' do
      context 'with fake calculators' do
        let(:inputs) do
          {
              total_savings: 1000
          }
        end
        include_context 'fake calculators'
        it 'calls calculator 1' do
          allow(calculator_1_class).to receive(:call).with(inputs).and_return(calculator_1)
          allow(calculator_2_class).to receive(:call).with(inputs).and_return(calculator_2)
          allow(calculator_3_class).to receive(:call).with(inputs).and_return(calculator_3)
          service.call(inputs, calculators: calculators)
          expect(calculator_1_class).to have_received(:call).with(inputs)
        end

        it 'calls calculator 2' do
          allow(calculator_1_class).to receive(:call).with(inputs).and_return(calculator_1)
          allow(calculator_2_class).to receive(:call).with(inputs).and_return(calculator_2)
          allow(calculator_3_class).to receive(:call).with(inputs).and_return(calculator_3)
          service.call(inputs, calculators: calculators)
          expect(calculator_2_class).to have_received(:call).with(inputs)
        end

        it 'calls calculator 3' do
          allow(calculator_1_class).to receive(:call).with(inputs).and_return(calculator_1)
          allow(calculator_2_class).to receive(:call).with(inputs).and_return(calculator_2)
          allow(calculator_3_class).to receive(:call).with(inputs).and_return(calculator_3)
          service.call(inputs, calculators: calculators)
          expect(calculator_3_class).to have_received(:call).with(inputs)
        end

        it 'returns an instance of CalculationService' do
          allow(calculator_1_class).to receive(:call).with(inputs).and_return(calculator_1)
          allow(calculator_2_class).to receive(:call).with(inputs).and_return(calculator_2)
          allow(calculator_3_class).to receive(:call).with(inputs).and_return(calculator_3)
          expect(service.call(inputs, calculators: calculators)).to be_a described_class
        end

        context 'help not available' do
          it 'provides access to messages on failure' do
            failure_reasons = [:reason1, :reason2]
            allow(calculator_1).to receive(:help_not_available?).and_return true
            allow(calculator_1).to receive(:messages).and_return failure_reasons
            allow(calculator_1_class).to receive(:call).with(inputs).and_return(calculator_1)
            allow(calculator_2_class).to receive(:call).with(inputs).and_return(calculator_2)
            allow(calculator_3_class).to receive(:call).with(inputs).and_return(calculator_3)
            expect(service.call(inputs, calculators: calculators)).to have_attributes help_not_available?: true, messages: failure_reasons
          end

          it 'prevents calculator 2 being called if calculator 1 fails' do
            failure_reasons = [:reason1, :reason2]
            allow(calculator_1).to receive(:help_not_available?).and_return true
            allow(calculator_1).to receive(:messages).and_return failure_reasons
            allow(calculator_1_class).to receive(:call).with(inputs).and_return(calculator_1)
            service.call(inputs, calculators: calculators)
            expect(calculator_2_class).not_to(have_received(:call))
          end

          it 'prevents calculator 3 being called if calculator 1 fails' do
            failure_reasons = [:reason1, :reason2]
            allow(calculator_1).to receive(:help_not_available?).and_return true
            allow(calculator_1).to receive(:messages).and_return failure_reasons
            allow(calculator_1_class).to receive(:call).with(inputs).and_return(calculator_1)
            service.call(inputs, calculators: calculators)
            expect(calculator_3_class).not_to(have_received(:call))
          end
        end

        context 'order of calculators called' do
          it 'calls the calculators in order' do
            calculators_called = []
            allow(calculator_1_class).to receive(:call).with(inputs) do
              calculators_called << 1
              calculator_1
            end
            allow(calculator_2_class).to receive(:call).with(inputs) do
              calculators_called << 2
              calculator_2
            end
            allow(calculator_3_class).to receive(:call).with(inputs) do
              calculators_called << 3
              calculator_3
            end
            service.call(inputs, calculators: calculators)
            expect(calculators_called).to eql [1, 2, 3]
          end

          it 'does not call the second calculator if the first had invalid inputs' do
            calculators_called = []
            allow(calculator_1_class).to receive(:call).with(inputs) do
              calculators_called << 1
              allow(calculator_1).to receive(:valid?).and_return false
              throw :invalid_inputs, calculator_1
            end
            allow(calculator_2_class).to receive(:call).with(inputs) do
              calculators_called << 2
              calculator_2
            end
            allow(calculator_3_class).to receive(:call).with(inputs) do
              calculators_called << 3
              calculator_3
            end
            service.call(inputs, calculators: calculators)
            expect(calculators_called).to eql [1]

          end
        end
      end

      context 'with standard calculators' do
        let(:inputs) do
          {
            total_savings: 1000
          }
        end

        it 'calls the disposable income calculator' do
          kls = class_double(TotalSavingsSubCalculationService).as_stubbed_const
          fake_calculation = instance_double(BaseSubCalculationService, 'Fake calculation', help_not_available?: false, help_available?: false, valid?: true)
          allow(kls).to receive(:call).with(inputs).and_return fake_calculation
          service.call(inputs)
          expect(kls).to have_received(:call).with(inputs)
        end
      end
    end

    describe '#help_available?' do
      let(:inputs) do
        {
            total_savings: 1000
        }
      end
      include_context 'fake calculators'
      it 'has help available if calculator 1 says it is available' do
        allow(calculator_1).to receive(:help_available?).and_return true
        allow(calculator_1).to receive(:messages).and_return []
        allow(calculator_1_class).to receive(:call).with(inputs).and_return(calculator_1)
        allow(calculator_2_class).to receive(:call).with(inputs).and_return(calculator_2)
        allow(calculator_3_class).to receive(:call).with(inputs).and_return(calculator_3)
        expect(service.call(inputs, calculators: calculators)).to have_attributes help_available?: true
      end

      it 'provides access to messages' do
        reasons = [:reason1, :reason2]
        allow(calculator_1).to receive(:help_not_available?).and_return false
        allow(calculator_1).to receive(:help_available?).and_return true
        allow(calculator_1).to receive(:messages).and_return reasons
        allow(calculator_1_class).to receive(:call).with(inputs).and_return(calculator_1)
        allow(calculator_2_class).to receive(:call).with(inputs).and_return(calculator_2)
        allow(calculator_3_class).to receive(:call).with(inputs).and_return(calculator_3)
        expect(service.call(inputs, calculators: calculators)).to have_attributes messages: reasons
      end
    end

    describe '#help_not_available?' do
      let(:inputs) do
        {
            total_savings: 1000
        }
      end

    end

    describe '#fields_required' do
      let(:inputs) do
        {
            total_savings: 1000
        }
      end
      include_context 'fake calculators'
      it 'returns any fields not provided in the input in the correct order' do
        allow(calculator_1_class).to receive(:call).with(inputs).and_return(calculator_1)
        allow(calculator_2_class).to receive(:call).with(inputs).and_return(calculator_2)
        allow(calculator_3_class).to receive(:call).with(inputs).and_return(calculator_3)
        expect(service.call(inputs, calculators: calculators)).to have_attributes fields_required: [:marital_status, :fee, :date_of_birth, :benefits_received, :number_of_children, :total_income]
      end
    end

    describe '#required_fields_affecting_likelyhood' do
      let(:inputs) do
        {
            total_savings: 1000
        }
      end
      include_context 'fake calculators'
      it 'returns any fields not provided that will affect the likelyhood and not those that just affect the amount' do
        allow(calculator_1_class).to receive(:call).with(inputs).and_return(calculator_1)
        allow(calculator_2_class).to receive(:call).with(inputs).and_return(calculator_2)
        allow(calculator_3_class).to receive(:call).with(inputs).and_return(calculator_3)
        expect(service.call(inputs, calculators: calculators)).to have_attributes required_fields_affecting_likelyhood: [:date_of_birth, :benefits_received, :total_income]
      end
    end
  end
end
