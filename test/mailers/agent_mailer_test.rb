require "test_helper"

class AgentMailerTest < ActionMailer::TestCase
  test "invitation links to the password page" do
    email = AgentMailer.invitation(users(:two))
    assert_equal [ "two@example.com" ], email.to
    assert_match "/invitations/", email.text_part.body.to_s
  end

  test "assigned names who assigned it and links to the ticket" do
    ticket = tickets(:invoice)
    email = AgentMailer.assigned(ticket, assigned_by: users(:two))

    assert_equal [ "one@example.com" ], email.to
    assert_match "Sam Support assigned you #{ticket.reference}", email.subject
    assert_match "/tickets/#{ticket.id}", email.text_part.body.to_s
  end
end
