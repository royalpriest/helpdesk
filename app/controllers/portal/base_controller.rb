# Customer-facing pages. Customers don't sign in; the private token in
# the URL is what gives them access to a single ticket.
module Portal
  class BaseController < ApplicationController
    allow_unauthenticated_access
    layout "portal"

    private
      def set_ticket
        @ticket = Ticket.find_by!(portal_token: params[:token] || params[:ticket_token])
      end
  end
end
