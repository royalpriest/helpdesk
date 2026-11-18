# Turns incoming email into tickets. A reply to an existing ticket
# (matched by the "[#42]" tag in the subject, or by the email's
# References header) is added to that ticket; anything else opens a new one.
class SupportMailbox < ApplicationMailbox
  before_processing :skip_duplicates

  def process
    ticket = existing_ticket || customer.tickets.create!(subject: subject)
    ticket.add_customer_message!(body: body, email_message_id: mail.message_id, attachments: attachments)
  end

  private
    def skip_duplicates
      bounced! if mail.message_id && Message.exists?(email_message_id: mail.message_id)
    end

    def customer
      @customer ||= Customer.find_or_create_by!(email_address: mail.from.first) do |c|
        c.name = mail[:from].display_names.first.to_s
      end
    end

    def existing_ticket
      ids = [ Ticket.id_from_subject(mail.subject), *referenced_ticket_ids ].compact
      customer.tickets.find_by(id: ids)
    end

    # Outgoing replies use Message-IDs like <ticket-42-message-7@helpdesk>.
    def referenced_ticket_ids
      Array(mail.references).filter_map { |ref| ref[/\Aticket-(\d+)-/, 1]&.to_i }
    end

    def subject
      mail.subject.presence || "(no subject)"
    end

    def attachments
      mail.attachments.reject(&:inline?).map do |attachment|
        {
          io: StringIO.new(attachment.decoded),
          filename: attachment.filename,
          content_type: attachment.mime_type
        }
      end
    end

    def body
      part = mail.multipart? ? (mail.text_part || mail.html_part) : mail
      text = part&.decoded.to_s
      text = ActionController::Base.helpers.strip_tags(text) if part&.mime_type == "text/html"
      EmailReply.strip_quoted(text).presence || "(empty message)"
    end
end
