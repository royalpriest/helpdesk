require "test_helper"

class TicketMailerTest < ActionMailer::TestCase
  test "reply goes to the customer with the ticket tag and portal link" do
    message = messages(:invoice_reply)
    email = TicketMailer.reply(message)

    assert_equal [ "casey@example.com" ], email.to
    assert_equal "Re: #{message.ticket.reference} Invoice question", email.subject
    assert_match "portal/tickets/casey-invoice-token", email.text_part.body.to_s
    assert_match "ticket-#{message.ticket.id}-message-#{message.id}@", email.message_id
    assert_equal "All", email["X-Auto-Response-Suppress"].value
  end
end
