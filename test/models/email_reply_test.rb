require "test_helper"

class EmailReplyTest < ActiveSupport::TestCase
  test "removes a Gmail-style quoted reply" do
    text = <<~MAIL
      That fixed it, thanks!

      On Tue, Nov 18, 2026 at 9:00 AM Support <support@example.com>
      wrote:

      > Try resetting your password.
      > Thanks
    MAIL

    assert_equal "That fixed it, thanks!", EmailReply.strip_quoted(text)
  end

  test "removes an Outlook-style quoted reply" do
    text = "Still broken.\r\n\r\n-----Original Message-----\r\nFrom: Support\r\nSent: Today\r\n\r\nTry again"
    assert_equal "Still broken.", EmailReply.strip_quoted(text)
  end

  test "removes stray quoted lines" do
    assert_equal "Yes\nok", EmailReply.strip_quoted("> did it work?\nYes\n> anything else?\nok")
  end

  test "leaves a plain message alone" do
    assert_equal "Hello there", EmailReply.strip_quoted("Hello there\n")
  end
end
