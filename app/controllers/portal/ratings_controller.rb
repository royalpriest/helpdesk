module Portal
  # The "how did we do?" page linked from the email sent when a ticket closes.
  # Opening the link doesn't record anything (email scanners open links too);
  # the customer confirms with a button and can add a comment.
  class RatingsController < BaseController
    before_action :set_ticket

    def new
      @rating = Ticket::RATINGS.include?(params[:rating]) ? params[:rating] : nil
    end

    def create
      rating = params.expect(ticket: %i[rating rating_comment])
      if Ticket::RATINGS.include?(rating[:rating])
        @ticket.rate!(rating[:rating], comment: rating[:rating_comment])
        redirect_to portal_ticket_path(@ticket.portal_token), notice: "Thanks for your feedback!"
      else
        redirect_to new_portal_ticket_rating_path(@ticket.portal_token), alert: "Pick good or not so good."
      end
    end
  end
end
