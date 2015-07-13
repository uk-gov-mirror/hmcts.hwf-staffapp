class HealthStatusController < ApplicationController
  def ping
    render json: Deployment.info
  end

  def healthcheck
    health = HealthStatus.current_status
    render json: health, status: health[:ok].equal?(true) ? 200 : 500
  end
end