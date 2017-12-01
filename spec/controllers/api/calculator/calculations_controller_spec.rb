require 'rails_helper'
module Api
  module Calculator
    RSpec.describe CalculationsController, type: :controller do
      render_views
      let(:auth_token) { 'my-big-secret' }
      let!(:calculator_service_class) { class_spy(::Calculator::CalculationService, 'Calculation service class', call: calculator_service).as_stubbed_const }

      before do
        allow(Settings.submission).to receive(:token).and_return('my-big-secret')
        controller.request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Token.encode_credentials(auth_token)
        controller.request.env['HTTP_ACCEPT'] = 'application/json'
        controller.request.env['HTTP_CONTENT_TYPE'] = 'application/json'
        post :create, calculation: calculation_data
      end

      describe 'POST #create' do
        describe 'when sent the correct authentication header' do
          let(:calculator_service) { instance_double(::Calculator::CalculationService, help_not_available?: false, help_available?: false, inputs: {}, failure_reasons: [], fields_required: []) }
          before do
            allow(calculator_service_class).to receive(:call).and_return(calculator_service)
          end
          let(:calculation_data) { { 'inputs' => {} } }
          it 'has success status' do
            expect(response).to have_http_status(:success)
          end

          describe 'body' do
            subject(:body) { response.body }

            it { is_expected.to include 'calculation' }
          end

          # @TODO Decide how to do this
          describe 'when sent invalid data from the public' do
            subject(:result) { JSON.parse(response.body)['result'] }

            let(:calculation_data) { { 'inputs' => { 'fee' => 'invalid' } } }

            it { is_expected.to be false }
          end
        end

        describe 'when sent the incorrect authentication header' do
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
