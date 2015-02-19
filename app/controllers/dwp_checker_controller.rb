class DwpCheckerController < ApplicationController
  def index
    @dwp_check = DwpCheck.new
  end

  def lookup
    @dwp_check = DwpCheck.new(dwp_params)

    if @dwp_check.valid?
      #todo create a new record
      #Add current_user and generated unique ID

      render json: get_dwp_result(@dwp_check)
    else
      render action: :index
    end
  end

  private

  def get_dwp_result(params)
    @results = "true #{params.inspect}"#todo create and call dwp lookup service
    @results
  end

  def dwp_params
    params.require(:dwp_check).permit(:last_name, :dob, :ni_number, :date_to_check)
  end
end
