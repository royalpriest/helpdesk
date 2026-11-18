class TicketsController < ApplicationController
  FILTERS = %w[mine unassigned open all].freeze

  before_action :set_ticket, only: %i[show update]

  before_action :load_ticket_list, only: %i[index show]

  def index
    @satisfaction = Ticket.satisfaction_score
  end

  def show
    @message = @ticket.messages.new
    @canned_replies = CannedReply.alphabetical
    @agents = User.active.alphabetical
    @inboxes = Inbox.alphabetical
    @other_tickets = @ticket.customer.tickets.where.not(id: @ticket.id).recent_first
  end

  def update
    if @ticket.update(ticket_params)
      notify_new_assignee
      request_rating
      redirect_to ticket_path(@ticket, list_params), notice: "Ticket updated."
    else
      redirect_to ticket_path(@ticket, list_params), alert: @ticket.errors.full_messages.to_sentence
    end
  end

  private
    # The list pane is on both the inbox and the ticket page, so agents can move
    # between tickets without losing their place.
    def load_ticket_list
      @filter = FILTERS.include?(params[:filter]) ? params[:filter] : "open"
      @query = params[:q].to_s.strip
      @tag = params[:tag].to_s.strip.downcase.presence
      @inboxes = Inbox.alphabetical.to_a
      @inbox = @inboxes.find { |inbox| inbox.id.to_s == params[:inbox] }
      @list_params = { filter: @filter, q: @query.presence, tag: @tag, inbox: @inbox&.id }.compact
      tickets = Ticket.for_filter(@filter, Current.user).tagged(@tag).search(@query)
      tickets = tickets.where(inbox: @inbox) if @inbox
      tickets = @filter == "all" ? tickets.recent_first : tickets.longest_waiting_first
      @tickets = tickets.includes(:customer, :assignee, :inbox, :tags, :latest_message)
      @tags = Tag.in_use.alphabetical
    end

    # Keeps the list pane's filter and search when coming back to the ticket.
    def list_params
      params.permit(:filter, :q, :tag, :inbox).to_h
    end

    def set_ticket
      @ticket = Ticket.find(params[:id])
    end

    # Lets an agent know when a teammate hands them a ticket.
    def notify_new_assignee
      return unless @ticket.saved_change_to_assignee_id?
      return if @ticket.assignee.nil? || @ticket.assignee == Current.user

      AgentMailer.assigned(@ticket, assigned_by: Current.user).deliver_later
    end

    # When an agent closes a ticket, ask the customer how it went.
    def request_rating
      @ticket.request_rating! if @ticket.saved_change_to_status?
    end

    def ticket_params
      params.expect(ticket: %i[assignee_id status inbox_id])
    end
end
