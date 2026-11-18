# Where an invited agent chooses their password.
class InvitationsController < ApplicationController
  allow_unauthenticated_access
  before_action :set_user_by_token

  def edit
  end

  def update
    if @user.update(params.permit(:password, :password_confirmation))
      start_new_session_for @user
      redirect_to root_path, notice: "Welcome aboard!"
    else
      redirect_to edit_invitation_path(params[:token]), alert: "Passwords did not match."
    end
  end

  private
    def set_user_by_token
      @user = User.active.find_by_token_for(:invitation, params[:token])
      redirect_to new_session_path, alert: "That invitation link is invalid or has expired." unless @user
    end
end
