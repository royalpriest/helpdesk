require "test_helper"

class TicketTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper

  test "new tickets are open and get a portal token" do
    ticket = customers(:casey).tickets.create!(subject: "Help")

    assert ticket.open?
    assert ticket.portal_token.present?
  end

  test "reads the ticket id from a reply subject" do
    assert_equal 42, Ticket.id_from_subject("Re: [#42] Can't log in")
    assert_nil Ticket.id_from_subject("Can't log in")
  end

  test "a customer message reopens a closed ticket" do
    ticket = tickets(:closed)
    ticket.add_customer_message!(body: "Actually, one more thing")

    assert ticket.reload.open?
    assert_equal "Actually, one more thing", ticket.messages.last.body
  end

  test "an agent reply marks the ticket pending and emails the customer" do
    ticket = tickets(:login)

    assert_enqueued_emails 1 do
      ticket.add_agent_reply!(user: users(:one), body: "Try resetting it again")
    end
    assert ticket.reload.pending?
    assert ticket.messages.last.from_agent?
  end

  test "filters by assignee" do
    assert_includes Ticket.assigned_to(users(:one)), tickets(:invoice)
    assert_includes Ticket.unassigned, tickets(:login)
    assert_not_includes Ticket.unassigned, tickets(:invoice)
  end

  test "search matches subjects without duplicates and escapes wildcards" do
    assert_equal [ tickets(:invoice) ], Ticket.search("invoice").to_a
    assert_empty Ticket.search("%")
    assert_equal Ticket.count, Ticket.search("").count
  end
end
