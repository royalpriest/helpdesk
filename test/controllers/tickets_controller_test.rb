require "test_helper"

class TicketsControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as users(:one) }

  test "requires sign in" do
    sign_out
    get tickets_path
    assert_redirected_to new_session_path
  end

  test "lists open tickets by default" do
    get tickets_path
    assert_response :success
    assert_select "##{dom_id(tickets(:login))}"
    assert_select "##{dom_id(tickets(:closed))}", count: 0
  end

  test "filters to my tickets" do
    get tickets_path(filter: "mine")
    assert_select "##{dom_id(tickets(:invoice))}"
    assert_select "##{dom_id(tickets(:login))}", count: 0
  end

  test "shows a ticket with its conversation" do
    get ticket_path(tickets(:invoice))
    assert_response :success
    assert_select ".message", 3
  end

  test "assigns a ticket" do
    patch ticket_path(tickets(:login)), params: { ticket: { assignee_id: users(:two).id } }
    assert_redirected_to ticket_path(tickets(:login))
    assert_equal users(:two), tickets(:login).reload.assignee
  end

  test "rejects an unknown status" do
    patch ticket_path(tickets(:login)), params: { ticket: { status: "bogus" } }
    assert tickets(:login).reload.open?
  end

  test "sends a reply" do
    assert_enqueued_emails 1 do
      post ticket_messages_path(tickets(:login)), params: { message: { body: "On it!" } }
    end
    assert_redirected_to ticket_path(tickets(:login))
    assert_equal users(:one), tickets(:login).messages.last.user
  end

  test "won't send a blank reply" do
    assert_no_difference "Message.count" do
      post ticket_messages_path(tickets(:login)), params: { message: { body: " " } }
    end
  end

  test "shows a count next to each filter" do
    get tickets_path
    assert_select ".filters a", text: /Mine\s+1/
    assert_select ".filters a", text: /All\s+3/
  end

  test "shows a message for an empty filter" do
    Ticket.update_all(assignee_id: users(:one).id)
    get tickets_path(filter: "unassigned")
    assert_select "p.empty", "Every open ticket has an owner."
  end

  test "adds an internal note without emailing the customer" do
    ticket = tickets(:login)
    assert_no_enqueued_emails do
      post ticket_messages_path(ticket), params: { message: { body: "Checking with billing" }, note: "Add internal note" }
    end

    note = ticket.messages.last
    assert note.internal?
    assert ticket.reload.open?
  end

  test "agents see internal notes" do
    get ticket_path(tickets(:invoice))
    assert_select ".message.internal", 1
  end

  test "lists the customer's other tickets" do
    get ticket_path(tickets(:login))
    assert_select ".other-tickets ##{dom_id(tickets(:invoice), :other)}"
    assert_select ".other-tickets ##{dom_id(tickets(:login), :other)}", count: 0
  end

  test "hides the other tickets section when there are none" do
    get ticket_path(tickets(:closed))
    assert_select ".other-tickets", count: 0
  end

  test "emails an agent when a teammate assigns them a ticket" do
    assert_enqueued_emails 1 do
      patch ticket_path(tickets(:login)), params: { ticket: { assignee_id: users(:two).id } }
    end
  end

  test "doesn't email you when you assign a ticket to yourself" do
    assert_no_enqueued_emails do
      patch ticket_path(tickets(:login)), params: { ticket: { assignee_id: users(:one).id } }
    end
  end

  test "doesn't email when only the status changes" do
    assert_no_enqueued_emails do
      patch ticket_path(tickets(:invoice)), params: { ticket: { status: "closed" } }
    end
  end

  test "searches message bodies" do
    get tickets_path(filter: "all", q: "invalid password")
    assert_select "##{dom_id(tickets(:login))}"
    assert_select "##{dom_id(tickets(:invoice))}", count: 0
  end

  test "searches customer email and keeps the filter" do
    get tickets_path(filter: "open", q: "jordan@")
    assert_select "table.tickets", count: 0
    assert_select "p.empty", /No tickets match/

    get tickets_path(filter: "all", q: "jordan@")
    assert_select "##{dom_id(tickets(:closed))}"
  end

  test "filters the inbox by inbox" do
    get tickets_path(filter: "all", inbox: inboxes(:billing).id)
    assert_select "##{dom_id(tickets(:invoice))}"
    assert_select "##{dom_id(tickets(:login))}", count: 0
  end

  test "moves a ticket to another inbox" do
    patch ticket_path(tickets(:login)), params: { ticket: { inbox_id: inboxes(:billing).id } }
    assert_equal inboxes(:billing), tickets(:login).reload.inbox
  end

  test "filters the inbox by tag" do
    get tickets_path(filter: "all", tag: "billing")
    assert_select "##{dom_id(tickets(:invoice))}"
    assert_select "##{dom_id(tickets(:login))}", count: 0
    assert_select "form.save-view"
  end

  test "shows tags on inbox rows" do
    get tickets_path
    assert_select "##{dom_id(tickets(:invoice))} a.tag", "billing"
  end
end
