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
    click_on "Internal note"
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

  test "changing a ticket's status saves straight away" do
    sign_in_as users(:one)

    click_on "Can't log in"
    select "Pending", from: "Status"

    assert_text "Ticket updated."
    assert_equal "pending", tickets(:login).reload.status
  end

  test "ctrl+enter sends the reply" do
    sign_in_as users(:one)

    click_on "Can't log in"
    fill_in "Reply", with: "Sent from the keyboard"
    find_field("Reply").send_keys [ :control, :enter ]

    assert_text "Reply sent."
    assert_selector ".message.agent", text: "Sent from the keyboard"
  end

  test "an agent searches the inbox" do
    sign_in_as users(:one)

    fill_in "Search tickets", with: "invoice"
    find_field("Search tickets").send_keys :enter

    assert_link "Invoice question"
    assert_no_link "Can't log in"
  end
end
