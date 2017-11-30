require 'rails_helper'
module Api
  module Calculator
    RSpec.describe CalculationsController, type: :controller do
      let(:auth_token) { 'my-big-secret' }

      before do
        allow(Settings.submission).to receive(:token).and_return('my-big-secret')
        controller.request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Token.encode_credentials(auth_token)
        post :create, calculation: calculation_data
      end

      describe 'POST #create' do
        describe 'when sent the correct authentication header' do
          subject(:returned) { response }
          let(:calculation_data) { { 'inputs' => {  } } }
          it { is_expected.to have_http_status(:success) }

          describe 'body' do
            subject(:body) { returned.body }

            it { is_expected.to include 'calculation' }
          end

          describe 'when sent invalid data from the public' do
            subject(:result) { JSON.parse(returned.body)['result'] }

            let(:calculation_data) { { 'inputs' => { 'fee' => 'invalid' } } }

            it { is_expected.to be false }
          end
        end

        describe 'when sent the incorrect authentication header' do
          subject { response }

          let(:auth_token) { 'different-big-secret' }

          it { is_expected.to have_http_status(:unauthorized) }
        end
      end
    end
  end
end
