class TicketsController < ApplicationController
  FILTERS = %w[mine unassigned open all].freeze

  before_action :set_ticket, only: %i[show update]

  def index
    @filter = FILTERS.include?(params[:filter]) ? params[:filter] : "open"
    @tickets = Ticket.for_filter(@filter, Current.user).includes(:customer, :assignee).recent_first
    @counts = FILTERS.index_with { |filter| Ticket.for_filter(filter, Current.user).count }
  end

  def show
    @message = @ticket.messages.new
    @canned_replies = CannedReply.alphabetical
    @agents = User.order(:name, :email_address)
  end

  def update
    if @ticket.update(ticket_params)
      redirect_to @ticket, notice: "Ticket updated."
    else
      redirect_to @ticket, alert: @ticket.errors.full_messages.to_sentence
    end
  end

  private
    def set_ticket
      @ticket = Ticket.find(params[:id])
    end

    def ticket_params
      params.expect(ticket: %i[assignee_id status])
    end
end
