# Resets a ticket's customer portal link, so an old or leaked link stops working.
class PortalLinksController < ApplicationController
  def update
    ticket = Ticket.find(params[:ticket_id])
    ticket.regenerate_portal_token
    redirect_to ticket_path(ticket, params.permit(:filter, :q, :tag, :inbox).to_h),
      notice: "Customer link reset. The old link no longer works."
  end
end
