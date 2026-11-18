require "test_helper"

class AgentsControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as users(:one) }

  test "lists agents" do
    get agents_path
    assert_select "td", "Sam Support"
    assert_select "td", "Deactivated"
  end

  test "invites an agent by email" do
    assert_enqueued_emails 1 do
      post agents_path, params: { user: { name: "New Person", email_address: "new@example.com" } }
    end
    assert_redirected_to agents_path
    assert User.find_by(email_address: "new@example.com").active?
  end

  test "won't invite a duplicate email" do
    assert_no_difference "User.count" do
      post agents_path, params: { user: { name: "Dupe", email_address: "two@example.com" } }
    end
    assert_response :unprocessable_entity
  end

  test "deactivating an agent signs them out and unassigns their open tickets" do
    users(:two).sessions.create!
    tickets(:login).update!(assignee: users(:two))

    delete agent_path(users(:two))

    assert_not users(:two).reload.active?
    assert_empty users(:two).sessions
    assert_nil tickets(:login).reload.assignee
  end

  test "can't deactivate yourself" do
    delete agent_path(users(:one))
    assert users(:one).reload.active?
  end

  test "reactivates an agent" do
    patch agent_path(users(:former))
    assert users(:former).reload.active?
  end

  test "deactivated agents can't sign in" do
    sign_out
    post session_path, params: { email_address: "former@example.com", password: "password" }
    assert_redirected_to new_session_path
    assert_nil cookies[:session_id].presence
  end

  test "deactivated agents aren't offered as assignees" do
    get ticket_path(tickets(:login))
    assert_select "option", text: "Former Agent", count: 0
  end
end
