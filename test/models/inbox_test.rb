require "test_helper"

class InboxTest < ActiveSupport::TestCase
  test "default is the inbox for SUPPORT_EMAIL" do
    assert_equal inboxes(:support), Inbox.default
  end

  test "new tickets go to the default inbox unless told otherwise" do
    assert_equal inboxes(:support), customers(:jordan).tickets.create!(subject: "Hi").inbox
  end

  test "matches addresses case-insensitively" do
    assert_equal inboxes(:billing), Inbox.for_addresses([ "nobody@example.com", "BILLING@example.com" ])
  end
end
