require "test_helper"

class PortalLinksControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as users(:one) }

  test "resetting the customer link makes the old one stop working" do
    ticket = tickets(:invoice)
    old_token = ticket.portal_token

    patch ticket_portal_link_path(ticket)

    assert_redirected_to ticket_path(ticket)
    assert_not_equal old_token, ticket.reload.portal_token

    get portal_ticket_path(old_token)
    assert_response :not_found

    get portal_ticket_path(ticket.portal_token)
    assert_response :success
  end

  test "keeps the list filter when coming back to the ticket" do
    ticket = tickets(:invoice)
    patch ticket_portal_link_path(ticket, filter: "mine")
    assert_redirected_to ticket_path(ticket, filter: "mine")
  end

  test "signed out visitors cannot reset a link" do
    sign_out
    ticket = tickets(:invoice)
    old_token = ticket.portal_token

    patch ticket_portal_link_path(ticket)

    assert_redirected_to new_session_path
    assert_equal old_token, ticket.reload.portal_token
  end

  test "the ticket page offers the reset button" do
    get ticket_path(tickets(:invoice))
    assert_select ".portal-link button", "Reset customer link"
  end
end
