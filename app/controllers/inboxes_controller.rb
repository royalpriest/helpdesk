# Lets admins add and rename the addresses customers can write to.
class InboxesController < ApplicationController
  before_action :require_admin
  before_action :set_inbox, only: %i[edit update destroy]

  def index
    @inboxes = Inbox.alphabetical
    @ticket_counts = Ticket.group(:inbox_id).count
  end

  def new
    @inbox = Inbox.new
  end

  def create
    @inbox = Inbox.new(inbox_params)
    if @inbox.save
      redirect_to inboxes_path, notice: "Inbox #{@inbox.name} added."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @inbox.update(inbox_params)
      redirect_to inboxes_path, notice: "Inbox #{@inbox.name} saved."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @inbox.destroy
      redirect_to inboxes_path, notice: "Inbox #{@inbox.name} removed."
    else
      redirect_to inboxes_path, alert: "#{@inbox.name} still has tickets, so it can't be removed."
    end
  end

  private
    def set_inbox
      @inbox = Inbox.find(params[:id])
    end

    def inbox_params
      params.expect(inbox: %i[name email_address])
    end
end
