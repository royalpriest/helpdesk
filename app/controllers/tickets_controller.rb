class TicketsController < ApplicationController
  FILTERS = %w[mine unassigned open all].freeze

  before_action :set_ticket, only: %i[show update]

  def index
    @filter = FILTERS.include?(params[:filter]) ? params[:filter] : "open"
    @query = params[:q].to_s.strip
    @tag = params[:tag].to_s.strip.downcase.presence
    @tickets = Ticket.for_filter(@filter, Current.user).tagged(@tag).search(@query)
      .includes(:customer, :assignee, :tags).recent_first
    @tags = Tag.in_use.alphabetical
    @saved_views = Current.user.saved_views.alphabetical
    @satisfaction = Ticket.satisfaction_score
    @counts = FILTERS.index_with { |filter| Ticket.for_filter(filter, Current.user).count }
  end

  def show
    @message = @ticket.messages.new
    @canned_replies = CannedReply.alphabetical
    @agents = User.active.alphabetical
    @other_tickets = @ticket.customer.tickets.where.not(id: @ticket.id).recent_first
  end

  def update
    if @ticket.update(ticket_params)
      notify_new_assignee
      request_rating
      redirect_to @ticket, notice: "Ticket updated."
    else
      redirect_to @ticket, alert: @ticket.errors.full_messages.to_sentence
    end
  end

  private
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
      return unless Rails.configuration.x.satisfaction_surveys
      return unless @ticket.saved_change_to_status? && @ticket.closed?

      @ticket.update!(rating: nil, rating_comment: nil, rated_at: nil)
      TicketMailer.rating_request(@ticket).deliver_later
    end

    def ticket_params
      params.expect(ticket: %i[assignee_id status])
    end
end
