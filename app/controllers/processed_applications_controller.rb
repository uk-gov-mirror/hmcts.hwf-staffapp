class ProcessedApplicationsController < ApplicationController
  include ProcessedViewsHelper

  def index
    authorize :application

    @applications = paginated_applications.map do |application|
      Views::ApplicationList.new(application)
    end
  end

  def show
    authorize application

    @form = Forms::Application::Delete.new(application)
    assign_views
  end

  def update
    @form = Forms::Application::Delete.new(application)
    @form.update_attributes(delete_params)
    authorize application
    save_and_respond_on_update
  end

  private

  def application
    @application ||= Application.find(params[:id])
  end

  def paginated_applications
    @paginate ||= paginate(policy_scope(Query::ProcessedApplications.new(current_user, sort_order).find))
  end

  def delete_params
    params.require(:application).permit(*Forms::Application::Delete.permitted_attributes.keys)
  end

  def save_and_respond_on_update
    if @form.save
      ResolverService.new(application, current_user).delete
      flash[:notice] = 'The application has been deleted'
      redirect_to(action: :index)
    else
      assign_views
      render :show
    end
  end

  def sort_order
    return nil if params['sort'].blank?
    case params['sort']
    when 'received_asc'
      return 'details.date_received asc'
    when 'received_desc'
      return 'details.date_received desc'
    when 'processed_asc'
      return 'completed_at asc'
    when 'processed_desc'
      return 'completed_at desc'
    when 'fee_asc'
      return 'details.fee asc'
    when 'fee_desc'
      return 'details.fee desc'
    end
  end
end
