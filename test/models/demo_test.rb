require "test_helper"

class DemoTest < ActiveSupport::TestCase
  test "reset wipes visitors' changes and loads the demo data again" do
    Ticket.first.update!(subject: "Defaced by a visitor")
    User.find_or_create_by!(email_address: "agent@example.com") { |u| u.name = "Demo Agent"; u.password = "password" }
      .update!(password: "changed-by-a-visitor")

    capture_io { Demo.reset! }

    assert_not Ticket.exists?(subject: "Defaced by a visitor")
    assert User.authenticate_by(email_address: "agent@example.com", password: "password")
    assert Ticket.exists?(subject: "Can't log in")
    assert_equal [ "Invoice question" ], Ticket.search("invoice").pluck(:subject)
  end
end
