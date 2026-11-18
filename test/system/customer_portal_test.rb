require "application_system_test_case"

class CustomerPortalTest < ApplicationSystemTestCase
  test "a customer reads the conversation and replies" do
    visit portal_ticket_path(tickets(:invoice).portal_token)

    assert_selector "h1", text: "Invoice question"
    assert_text "Sure, it's attached."
    assert_no_text "Customer is on the annual plan." # internal note

    fill_in "Add a reply", with: "Thanks, got it!"
    click_on "Send"

    assert_text "Message sent."
    assert_selector ".message.customer", text: "Thanks, got it!"
  end
end
