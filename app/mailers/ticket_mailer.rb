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
         from: @ticket.inbox.from_address,
         reply_to: @ticket.inbox.email_address,
         subject: "Re: #{@ticket.reference} #{@ticket.subject}"
  end

  private
    def mail_domain
      @ticket.inbox.domain
    end
end
