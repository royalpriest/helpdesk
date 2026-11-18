require "test_helper"

class Portal::TicketsControllerTest < ActionDispatch::IntegrationTest
  test "a customer sees their ticket without signing in" do
    get portal_ticket_path("casey-invoice-token")
    assert_response :success
    assert_select "h1", "Invoice question"
    assert_select ".message", 2
  end

  test "a wrong token is not found" do
    get portal_ticket_path("nope")
    assert_response :not_found
  end

  test "a customer can reply from the portal" do
    ticket = tickets(:invoice)
    post portal_ticket_messages_path(ticket.portal_token), params: { message: { body: "Got it, thanks" } }

    assert_redirected_to portal_ticket_path(ticket.portal_token)
    assert_equal "Got it, thanks", ticket.messages.last.body
    assert_nil ticket.messages.last.user
    assert ticket.reload.open?
  end

  test "lists attachments on messages" do
    messages(:invoice_first).attachments.attach(io: StringIO.new("pdf"), filename: "invoice.pdf")
    get portal_ticket_path("casey-invoice-token")
    assert_select ".attachments a", "invoice.pdf"
  end
end
