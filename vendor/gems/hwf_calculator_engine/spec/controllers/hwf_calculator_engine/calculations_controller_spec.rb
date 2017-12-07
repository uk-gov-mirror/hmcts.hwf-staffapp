require 'rails_helper'
module HwfCalculatorEngine
  RSpec.describe CalculationsController, type: :controller do
    routes { Engine.routes }
    render_views
    let(:auth_token) { 'my-big-secret' }
    let!(:calculator_service_class) { class_spy(CalculationService, 'Calculation service class', call: calculator_service).as_stubbed_const }
    let!(:calculator_form_class) { class_spy(::HwfCalculatorEngine::Forms::Calculation, new: calculator_form).as_stubbed_const }

    before do
      controller.request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Token.encode_credentials(auth_token)
      controller.request.env['HTTP_ACCEPT'] = 'application/json'
      controller.request.env['HTTP_CONTENT_TYPE'] = 'application/json'
    end

    describe 'POST #create' do
      describe 'when sent the correct authentication header' do
        let(:calculator_service) { instance_double(CalculationService, help_not_available?: false, help_available?: false, inputs: {}, failure_reasons: [], fields_required: []) }
        let(:calculator_form) { instance_double(::HwfCalculatorEngine::Forms::Calculation, to_h: {}) }
        before do
          allow(calculator_service_class).to receive(:call).and_return(calculator_service)
        end
        let(:calculation_data) { { 'inputs' => {'date_of_birth' => '2000-01-01'} } }
        it 'has success status' do
          post :create, calculation: calculation_data
          expect(response).to have_http_status(:success)
        end

        it 'sends the correct part of the data to the form' do
          post :create, calculation: calculation_data
          expect(calculator_form_class).to have_received(:new).with(calculation_data['inputs'])
        end

        it 'sends the result of the form to the service' do
          # Arrange
          example_hash = { 'date_of_birth' => Date.parse('25 December 1999') }
          allow(calculator_form).to receive(:to_h).and_return example_hash

          # Act
          post :create, calculation: calculation_data

          # Assert
          expect(calculator_service_class).to have_received(:call).with(example_hash)
        end

        context 'unwanted params' do
          let(:calculation_data) { { 'inputs' => {'wrong_param' => '2000-01-01'} } }
          it 'filters out unwanted parameters from reaching the form' do
            post :create, calculation: calculation_data
            expect(calculator_form_class).to have_received(:new).with({})
          end
        end

        describe 'body' do
          before { post :create, calculation: calculation_data }
          subject(:body) { response.body }

          it { is_expected.to include 'calculation' }
        end

        # @TODO Decide how to do this
        describe 'when sent invalid data from the public' do
          before { post :create, calculation: calculation_data }
          subject(:result) { JSON.parse(response.body)['result'] }

          let(:calculation_data) { { 'inputs' => { 'fee' => 'invalid' } } }

          it { is_expected.to be false }
        end
      end
    end
  end
end
