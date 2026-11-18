# Emails an agent's reply to the customer.
class TicketMailer < ApplicationMailer
  def reply(message)
    @message = message
    @ticket = message.ticket

    headers["Message-ID"] = "<ticket-#{@ticket.id}-message-#{message.id}@#{mail_domain}>"
    headers["References"] = "<ticket-#{@ticket.id}@#{mail_domain}>"
    # Asks Outlook and Exchange not to send out-of-office replies to this email.
    headers["X-Auto-Response-Suppress"] = "All"

    mail to: @ticket.customer.email_address,
         reply_to: Rails.configuration.x.support_email,
         subject: "Re: #{@ticket.reference} #{@ticket.subject}"
  end

  # Asks the customer to rate how their closed ticket was handled.
  def rating_request(ticket)
    @ticket = ticket
    headers["X-Auto-Response-Suppress"] = "All"
    mail to: ticket.customer.email_address,
         subject: "How did we do? #{ticket.reference} #{ticket.subject}"
  end

  private
    def mail_domain
      Rails.configuration.x.support_email.split("@").last
    end
end
