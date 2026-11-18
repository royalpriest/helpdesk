require "test_helper"

class SupportMailboxTest < ActionMailbox::TestCase
  test "a new email opens a ticket for a new customer" do
    assert_difference [ "Ticket.count", "Customer.count" ], 1 do
      receive_inbound_email_from_mail \
        to: "support@example.com", from: "Riley <riley@example.com>",
        subject: "Where is my order?", body: "It hasn't arrived yet."
    end

    ticket = Ticket.last
    assert_equal "Where is my order?", ticket.subject
    assert_equal "riley@example.com", ticket.customer.email_address
    assert_equal "Riley", ticket.customer.name
    assert_equal "It hasn't arrived yet.", ticket.messages.first.body
  end

  test "a reply with the ticket tag in the subject joins the existing ticket" do
    ticket = tickets(:closed)

    assert_no_difference "Ticket.count" do
      assert_difference -> { ticket.messages.count }, 1 do
        receive_inbound_email_from_mail \
          to: "support@example.com", from: "jordan@example.com",
          subject: "Re: #{ticket.reference} Old question", body: "Still broken."
      end
    end
    assert ticket.reload.open?
  end

  test "a reply matched by References header joins the existing ticket" do
    ticket = tickets(:login)

    assert_no_difference "Ticket.count" do
      receive_inbound_email_from_mail \
        to: "support@example.com", from: "casey@example.com", subject: "Re: hello",
        body: "Thanks", references: "<ticket-#{ticket.id}-message-1@example.com>"
    end
    assert_equal "Thanks", ticket.messages.last.body
  end

  test "someone else can't post to a ticket by guessing its number" do
    ticket = tickets(:login)

    assert_difference "Ticket.count", 1 do
      receive_inbound_email_from_mail \
        to: "support@example.com", from: "stranger@example.com",
        subject: "Re: #{ticket.reference} Can't log in", body: "Let me in"
    end
    assert_not_equal "Let me in", ticket.messages.last.body
  end

  test "only the new text of an email reply is saved" do
    ticket = tickets(:login)

    receive_inbound_email_from_mail \
      to: "support@example.com", from: "casey@example.com",
      subject: "Re: #{ticket.reference} Can't log in",
      body: "Works now!\n\nOn Tue, Nov 18, 2026 at 9:00 AM Support <support@example.com> wrote:\n> Try again"

    assert_equal "Works now!", ticket.messages.last.body
  end
end
