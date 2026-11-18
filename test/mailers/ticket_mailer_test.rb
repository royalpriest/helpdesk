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

  test "rating request links to both ratings in the portal" do
    email = TicketMailer.rating_request(tickets(:closed))

    assert_equal [ "jordan@example.com" ], email.to
    assert_equal [ tickets(:closed).inbox.email_address ], email.from
    body = email.text_part.body.to_s
    assert_match "/portal/tickets/jordan-closed-token/rating/new?rating=good", body
    assert_match "/portal/tickets/jordan-closed-token/rating/new?rating=bad", body
  end

  test "reply is sent from the ticket's inbox" do
    email = TicketMailer.reply(messages(:invoice_reply))

    assert_equal [ "billing@example.com" ], email.from
    assert_equal "Billing <billing@example.com>", email[:from].value
    assert_equal [ "billing@example.com" ], email.reply_to
  end
end
