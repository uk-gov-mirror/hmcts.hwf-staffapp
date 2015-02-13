class Users::InvitationsController < Devise::InvitationsController
  respond_to :html
  before_action :authenticate_user!
  load_and_authorize_resource class: User

  private

  def invite_resource
    resource_class.invite!(invite_params, current_inviter)
  end

  def invite_params
    params.require(:user).permit(:email, :role)
  end

end