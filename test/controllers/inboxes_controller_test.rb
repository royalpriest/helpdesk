require "test_helper"

class InboxesControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as users(:one) }

  test "lists inboxes" do
    get inboxes_path
    assert_select "td", "billing@example.com"
  end

  test "adds an inbox" do
    assert_difference "Inbox.count", 1 do
      post inboxes_path, params: { inbox: { name: "Sales", email_address: " Sales@Example.com " } }
    end
    assert_equal "sales@example.com", Inbox.last.email_address
  end

  test "rejects a bad address" do
    post inboxes_path, params: { inbox: { name: "Oops", email_address: "not an email" } }
    assert_response :unprocessable_entity
  end

  test "renames an inbox" do
    patch inbox_path(inboxes(:billing)), params: { inbox: { name: "Accounts" } }
    assert_equal "Accounts", inboxes(:billing).reload.name
  end

  test "won't remove an inbox that has tickets" do
    assert_no_difference "Inbox.count" do
      delete inbox_path(inboxes(:billing))
    end

    empty = Inbox.create!(name: "Empty", email_address: "empty@example.com")
    assert_difference "Inbox.count", -1 do
      delete inbox_path(empty)
    end
  end

  test "only admins can manage inboxes" do
    sign_out
    sign_in_as users(:two)

    get inboxes_path
    assert_redirected_to root_path
  end
end
