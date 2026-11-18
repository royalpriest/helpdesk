require "application_system_test_case"

class AgentRepliesTest < ApplicationSystemTestCase
  include ActionMailer::TestHelper

  test "an agent inserts a canned reply and sends it" do
    sign_in_as users(:one)

    click_on "Can't log in"
    select "Password reset", from: "canned_reply"
    assert_field "Reply", with: canned_replies(:reset).body

    click_on "Send reply"

    assert_text "Reply sent."
    assert_selector ".message.agent", text: canned_replies(:reset).body
    assert_equal "pending", tickets(:login).reload.status
  end

  test "an agent adds an internal note" do
    sign_in_as users(:one)

    click_on "Can't log in"
    fill_in "Reply", with: "Asked billing to check the account"
    click_on "Add internal note"

    assert_text "Note added."
    assert_selector ".message.internal", text: "Asked billing to check the account"
  end

  test "an agent assigns a ticket to themselves" do
    sign_in_as users(:one)

    click_on "Can't log in"
    click_on "Assign to me"

    assert_text "Ticket updated."
    assert_select "Assignee", selected: "Alex Agent"
  end

  test "an agent searches the inbox" do
    sign_in_as users(:one)

    fill_in "q", with: "invoice"
    click_on "Search"

    assert_link "Invoice question"
    assert_no_link "Can't log in"
  end
end
