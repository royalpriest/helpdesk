require "test_helper"

class ApplicationCable::ConnectionTest < ActionCable::Connection::TestCase
  test "connects a signed-in agent" do
    session = users(:one).sessions.create!
    cookies.signed[:session_id] = session.id

    connect
    assert_equal users(:one), connection.current_user
  end

  test "lets portal visitors connect without signing in" do
    connect
    assert_nil connection.current_user
  end

  test "doesn't treat a deactivated agent as signed in" do
    session = users(:former).sessions.create!
    cookies.signed[:session_id] = session.id

    connect
    assert_nil connection.current_user
  end
end
