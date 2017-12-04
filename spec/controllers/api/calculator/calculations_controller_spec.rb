require 'rails_helper'
module Api
  module Calculator
    RSpec.describe CalculationsController, type: :controller do
      render_views
      let(:auth_token) { 'my-big-secret' }
      let!(:calculator_service_class) { class_spy(::Calculator::CalculationService, 'Calculation service class', call: calculator_service).as_stubbed_const }
      let!(:calculator_form_class) { class_spy(::Forms::Calculator::Calculation, new: calculator_form).as_stubbed_const }

      before do
        allow(Settings.submission).to receive(:token).and_return('my-big-secret')
        controller.request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Token.encode_credentials(auth_token)
        controller.request.env['HTTP_ACCEPT'] = 'application/json'
        controller.request.env['HTTP_CONTENT_TYPE'] = 'application/json'
      end

      describe 'POST #create' do
        describe 'when sent the correct authentication header' do
          let(:calculator_service) { instance_double(::Calculator::CalculationService, help_not_available?: false, help_available?: false, inputs: {}, failure_reasons: [], fields_required: []) }
          let(:calculator_form) { instance_double(::Forms::Calculator::Calculation, to_h: {}) }
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

        describe 'when sent the incorrect authentication header' do
          let(:calculator_form) { instance_double(::Forms::Calculator::Calculation, to_h: {}) }
          before { post :create, calculation: calculation_data }
          subject { response }
          let(:calculation_data) { { 'inputs' => {} } }
          let(:auth_token) { 'different-big-secret' }
          let(:calculator_service) { instance_double(::Calculator::CalculationService, help_not_available?: false, help_available?: false, inputs: {}, failure_reasons: [], fields_required: []) }

          it { is_expected.to have_http_status(:unauthorized) }
        end
      end
    end
  end
end
