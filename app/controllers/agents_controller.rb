# Lets admins invite, deactivate and reactivate agents, and choose who else is an admin.
class AgentsController < ApplicationController
  before_action :require_admin
  before_action :set_agent, only: %i[destroy reactivate make_admin remove_admin]

  def index
    @agents = User.alphabetical
  end

  def new
    @agent = User.new
  end

  def create
    @agent = User.invite!(**agent_params.to_h.symbolize_keys)
    redirect_to agents_path, notice: "Invitation sent to #{@agent.email_address}."
  rescue ActiveRecord::RecordInvalid => e
    @agent = e.record
    render :new, status: :unprocessable_entity
  end

  # Deactivates rather than deletes, so their past replies keep their name.
  def destroy
    if @agent == Current.user
      redirect_to agents_path, alert: "You can't deactivate yourself."
    else
      @agent.deactivate!
      redirect_to agents_path, notice: "#{@agent.display_name} has been deactivated."
    end
  end

  def reactivate
    @agent.reactivate!
    redirect_to agents_path, notice: "#{@agent.display_name} can sign in again."
  end

  def make_admin
    @agent.update!(admin: true)
    redirect_to agents_path, notice: "#{@agent.display_name} is now an admin."
  end

  def remove_admin
    if @agent.last_admin?
      redirect_to agents_path, alert: "There has to be at least one admin."
    else
      @agent.update!(admin: false)
      redirect_to agents_path, notice: "#{@agent.display_name} is no longer an admin."
    end
  end

  private
    def set_agent
      @agent = User.find(params[:id])
    end

    def agent_params
      params.expect(user: %i[name email_address])
    end
end
