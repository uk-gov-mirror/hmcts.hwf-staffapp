module Api
  module Calculator
    class CalculationsController < ApplicationController
      protect_from_forgery with: :null_session, only: proc { |c| c.request.format.json? }

      skip_before_action :authenticate_user!
      skip_after_action :verify_authorized

      def create
        ::Calculator::CalculationService.call(calculation_params.to_hash)
      end

      private

      def calculation_params
        params.require(:calculation).permit(:inputs)
      end
    end
  end
end