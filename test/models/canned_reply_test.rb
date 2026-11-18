require "test_helper"

class CannedReplyTest < ActiveSupport::TestCase
  test "fills in placeholders" do
    reply = CannedReply.new(title: "Hi", body: "Hi {{customer_name}}, about {{ ticket_reference }}. {{agent_name}}")
    text = reply.render_for(ticket: tickets(:login), agent: users(:one))

    assert_equal "Hi Casey Customer, about #{tickets(:login).reference}. Alex Agent", text
  end

  test "leaves unknown placeholders alone" do
    reply = CannedReply.new(title: "Hi", body: "Hi {{first_name}}")
    assert_equal "Hi {{first_name}}", reply.render_for(ticket: tickets(:login), agent: users(:one))
  end
end
