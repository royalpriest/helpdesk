# Lets agents invite, deactivate and reactivate their teammates.
class AgentsController < ApplicationController
  before_action :set_agent, only: %i[update destroy]

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

  # Reactivates a deactivated agent.
  def update
    @agent.reactivate!
    redirect_to agents_path, notice: "#{@agent.display_name} can sign in again."
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

  private
    def set_agent
      @agent = User.find(params[:id])
    end

    def agent_params
      params.expect(user: %i[name email_address])
    end
end
