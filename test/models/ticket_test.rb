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

  test "remembers when a ticket started waiting on the customer" do
    ticket = tickets(:login)
    ticket.add_agent_reply!(user: users(:one), body: "Does this help?")
    assert_in_delta Time.current, ticket.pending_since, 5

    ticket.add_customer_message!(body: "Yes")
    assert_nil ticket.reload.pending_since
  end

  test "satisfaction score counts recent ratings only" do
    assert_nil Ticket.satisfaction_score

    tickets(:login).rate!("good")
    tickets(:invoice).rate!("good")
    tickets(:closed).rate!("bad")
    assert_equal 67, Ticket.satisfaction_score

    tickets(:closed).update!(rated_at: 2.months.ago)
    assert_equal 100, Ticket.satisfaction_score
  end

  test "search matches words anywhere in the conversation, as prefixes" do
    assert_equal [ tickets(:login) ], Ticket.search("invalid pass").to_a
    assert_equal [ tickets(:invoice) ], Ticket.search("annual").to_a # internal note
    assert_equal [ tickets(:closed) ], Ticket.search("jordan@example").to_a
  end

  test "new messages and tickets are searchable straight away" do
    tickets(:login).add_customer_message!(body: "Still seeing the kaleidoscope error")
    assert_equal [ tickets(:login) ], Ticket.search("kaleidoscope").to_a

    ticket = customers(:jordan).tickets.create!(subject: "Refund request")
    assert_includes Ticket.search("refund"), ticket
  end

  test "renaming a customer updates search" do
    customers(:casey).update!(name: "Casey Zylberstein")
    assert_equal 2, Ticket.search("zylberstein").count
  end

  test "deleted tickets drop out of search" do
    tickets(:closed).destroy
    assert_empty Ticket.search("jordan")
  end

  test "tracks how long the customer has been waiting on the team" do
    ticket = tickets(:closed)
    assert_nil ticket.waiting_for

    ticket.add_customer_message!(body: "Me again")
    assert ticket.open?
    assert_in_delta Time.current, ticket.waiting_since, 5
    first_wait = ticket.waiting_since

    travel 2.hours do
      ticket.add_customer_message!(body: "Anyone there?")
      assert_equal first_wait, ticket.reload.waiting_since, "a follow-up doesn't reset the clock"
      assert_equal "soon", ticket.waiting_level
    end

    ticket.add_agent_reply!(user: users(:one), body: "Here!")
    assert_nil ticket.reload.waiting_since
  end
end
