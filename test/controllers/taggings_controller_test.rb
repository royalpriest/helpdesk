require "test_helper"

class TaggingsControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as users(:one) }

  test "tags a ticket, creating the tag if needed" do
    assert_difference "Tag.count", 1 do
      post ticket_taggings_path(tickets(:login)), params: { tagging: { name: "  Login Issues " } }
    end
    assert_redirected_to ticket_path(tickets(:login))
    assert_equal [ "login-issues" ], tickets(:login).tags.map(&:name)
  end

  test "reuses an existing tag and doesn't tag twice" do
    assert_no_difference [ "Tag.count", "Tagging.count" ] do
      post ticket_taggings_path(tickets(:invoice)), params: { tagging: { name: "Billing" } }
    end
  end

  test "removes a tag" do
    delete ticket_tagging_path(tickets(:invoice), "billing")
    assert_empty tickets(:invoice).reload.tags
  end

  test "shows tags on the ticket page" do
    get ticket_path(tickets(:invoice))
    assert_select ".ticket-tags .tag a", "billing"
  end
end
