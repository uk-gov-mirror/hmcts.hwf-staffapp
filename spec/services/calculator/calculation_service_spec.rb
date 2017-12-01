require 'rails_helper'
module Calculator
  RSpec.describe CalculationService do
    subject(:service) { described_class }

    shared_context 'fake calculators' do
      let(:calculator_1_class) { class_spy(::Calculator::BaseSubCalculationService, 'Calculator 1 class') }
      let(:calculator_2_class) { class_spy(::Calculator::BaseSubCalculationService, 'Calculator 2 class') }
      let(:calculator_3_class) { class_spy(::Calculator::BaseSubCalculationService, 'Calculator 3 class') }

      let(:calculator_1) do
        instance_double(::Calculator::BaseSubCalculationService, 'Calculator 1', help_not_available?: false, help_available?: false)
      end

      let(:calculator_2) do
        instance_double(::Calculator::BaseSubCalculationService, 'Calculator 2', help_not_available?: false, help_available?: false)
      end

      let(:calculator_3) do
        instance_double(::Calculator::BaseSubCalculationService, 'Calculator 3', help_not_available?: false, help_available?: false)
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
          it 'provides access to failure reasons on failure' do
            failure_reasons = [:reason1, :reason2]
            allow(calculator_1).to receive(:help_not_available?).and_return true
            allow(calculator_1).to receive(:failure_reasons).and_return failure_reasons
            allow(calculator_1_class).to receive(:call).with(inputs).and_return(calculator_1)
            allow(calculator_2_class).to receive(:call).with(inputs).and_return(calculator_2)
            allow(calculator_3_class).to receive(:call).with(inputs).and_return(calculator_3)
            expect(service.call(inputs, calculators: calculators)).to have_attributes help_not_available?: true, failure_reasons: failure_reasons
          end

          it 'prevents calculator 2 being called if calculator 1 fails' do
            failure_reasons = [:reason1, :reason2]
            allow(calculator_1).to receive(:help_not_available?).and_return true
            allow(calculator_1).to receive(:failure_reasons).and_return failure_reasons
            allow(calculator_1_class).to receive(:call).with(inputs).and_return(calculator_1)
            service.call(inputs, calculators: calculators)
            expect(calculator_2_class).not_to(have_received(:call))
          end

          it 'prevents calculator 3 being called if calculator 1 fails' do
            failure_reasons = [:reason1, :reason2]
            allow(calculator_1).to receive(:help_not_available?).and_return true
            allow(calculator_1).to receive(:failure_reasons).and_return failure_reasons
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

        end
      end

      context 'with standard calculators' do
        let(:inputs) do
          {
            total_savings: 1000
          }
        end

        it 'calls the disposable calculator' do
          kls = class_double(Calculator::DisposableCalculationService).as_stubbed_const
          fake_calculation = instance_double(::Calculator::BaseSubCalculationService, 'Fake calculation', help_not_available?: false, help_available?: false)
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
        allow(calculator_1_class).to receive(:call).with(inputs).and_return(calculator_1)
        allow(calculator_2_class).to receive(:call).with(inputs).and_return(calculator_2)
        allow(calculator_3_class).to receive(:call).with(inputs).and_return(calculator_3)
        expect(service.call(inputs, calculators: calculators)).to have_attributes help_available?: true
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
  end
end
