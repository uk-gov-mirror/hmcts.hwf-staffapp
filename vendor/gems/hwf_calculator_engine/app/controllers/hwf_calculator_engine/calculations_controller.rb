module HwfCalculatorEngine
  class CalculationsController < ApplicationController
    protect_from_forgery with: :null_session, only: proc { |c| c.request.format.json? }

    skip_before_action :authenticate_user!
    skip_after_action :verify_authorized

    def create
      form = HwfCalculatorEngine::Forms::Calculation.new(calculation_params.to_hash.fetch('inputs', {}))
      @calculation = CalculationService.call(form.to_h)
      @fields = {}
    end

    private

    def calculation_params
      params.require(:calculation).permit(inputs: [:marital_status, :fee, :date_of_birth, :total_savings, :benefits_received, :number_of_children, :total_income])
    end
  end
end