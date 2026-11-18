require "test_helper"

class CannedRepliesControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as users(:one) }

  test "lists canned replies" do
    get canned_replies_path
    assert_select "li", text: /Password reset/
  end

  test "creates a canned reply" do
    assert_difference "CannedReply.count", 1 do
      post canned_replies_path, params: { canned_reply: { title: "Hours", body: "We're open 9 to 5." } }
    end
    assert_redirected_to canned_replies_path
  end

  test "shows errors for an invalid canned reply" do
    post canned_replies_path, params: { canned_reply: { title: "", body: "" } }
    assert_response :unprocessable_entity
  end

  test "updates and deletes a canned reply" do
    reply = canned_replies(:reset)
    patch canned_reply_path(reply), params: { canned_reply: { title: "Reset" } }
    assert_equal "Reset", reply.reload.title

    assert_difference "CannedReply.count", -1 do
      delete canned_reply_path(reply)
    end
  end

  test "canned replies show up on the ticket page" do
    get ticket_path(tickets(:login))
    assert_select "select#canned_reply option", text: "Password reset"
  end
end
