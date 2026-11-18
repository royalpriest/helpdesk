# Agent replies on a ticket.
class MessagesController < ApplicationController
  def create
    ticket = Ticket.find(params[:ticket_id])
    body = params.expect(message: [ :body ])[:body]

    if body.blank?
      redirect_to ticket, alert: "Reply can't be blank."
    else
      ticket.add_agent_reply!(user: Current.user, body: body)
      redirect_to ticket, notice: "Reply sent."
    end
  end
end
