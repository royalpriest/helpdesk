require "test_helper"

class SupportMailboxTest < ActionMailbox::TestCase
  test "a new email opens a ticket for a new customer" do
    assert_difference [ "Ticket.count", "Customer.count" ], 1 do
      receive_inbound_email_from_mail \
        to: "support@example.com", from: "Riley <riley@example.com>",
        subject: "Where is my order?", body: "It hasn't arrived yet."
    end

    ticket = Ticket.last
    assert_equal "Where is my order?", ticket.subject
    assert_equal "riley@example.com", ticket.customer.email_address
    assert_equal "Riley", ticket.customer.name
    assert_equal "It hasn't arrived yet.", ticket.messages.first.body
  end

  test "a reply with the ticket tag in the subject joins the existing ticket" do
    ticket = tickets(:closed)

    assert_no_difference "Ticket.count" do
      assert_difference -> { ticket.messages.count }, 1 do
        receive_inbound_email_from_mail \
          to: "support@example.com", from: "jordan@example.com",
          subject: "Re: #{ticket.reference} Old question", body: "Still broken."
      end
    end
    assert ticket.reload.open?
  end

  test "a reply matched by References header joins the existing ticket" do
    ticket = tickets(:login)

    assert_no_difference "Ticket.count" do
      receive_inbound_email_from_mail \
        to: "support@example.com", from: "casey@example.com", subject: "Re: hello",
        body: "Thanks", references: "<ticket-#{ticket.id}-message-1@example.com>"
    end
    assert_equal "Thanks", ticket.messages.last.body
  end

  test "someone else can't post to a ticket by guessing its number" do
    ticket = tickets(:login)

    assert_difference "Ticket.count", 1 do
      receive_inbound_email_from_mail \
        to: "support@example.com", from: "stranger@example.com",
        subject: "Re: #{ticket.reference} Can't log in", body: "Let me in"
    end
    assert_not_equal "Let me in", ticket.messages.last.body
  end

  test "only the new text of an email reply is saved" do
    ticket = tickets(:login)

    receive_inbound_email_from_mail \
      to: "support@example.com", from: "casey@example.com",
      subject: "Re: #{ticket.reference} Can't log in",
      body: "Works now!\n\nOn Tue, Nov 18, 2026 at 9:00 AM Support <support@example.com> wrote:\n> Try again"

    assert_equal "Works now!", ticket.messages.last.body
  end

  test "saves attachments from the email" do
    mail = Mail.new do
      to "support@example.com"
      from "casey@example.com"
      subject "Screenshot of the error"
      body "See attached"
      add_file filename: "error.txt", content: "Something went wrong"
    end

    receive_inbound_email_from_source(mail.to_s)

    message = Ticket.last.messages.last
    assert_equal "See attached", message.body
    assert_equal [ "error.txt" ], message.attachments.map { |a| a.filename.to_s }
    assert_equal "Something went wrong", message.attachments.first.download
  end

  test "ignores automatic emails" do
    automatic = {
      "Auto-Submitted" => "auto-replied",
      "Precedence" => "bulk",
      "X-Autoreply" => "yes",
      "X-Autorespond" => "Out of office"
    }

    automatic.each do |header, value|
      mail = Mail.new(to: "support@example.com", from: "casey@example.com", subject: "Out of office", body: "I'm away")
      mail[header] = value

      assert_no_difference [ "Ticket.count", "Message.count" ], "#{header}: #{value} should be ignored" do
        inbound = receive_inbound_email_from_source(mail.to_s)
        assert inbound.bounced?
      end
    end
  end

  test "ignores bounces from mail servers" do
    assert_no_difference [ "Ticket.count", "Message.count" ] do
      receive_inbound_email_from_mail \
        to: "support@example.com", from: "MAILER-DAEMON@mail.example.com",
        subject: "Undelivered Mail Returned to Sender", body: "Delivery failed"
    end
  end

  test "ignores delivery status reports" do
    mail = Mail.new(to: "support@example.com", from: "casey@example.com", subject: "Delivery Status Notification")
    mail.content_type = "multipart/report; report-type=delivery-status"
    mail.text_part = "The message could not be delivered"

    assert_no_difference "Ticket.count" do
      receive_inbound_email_from_source(mail.to_s)
    end
  end

  test "still accepts a person's email that says Auto-Submitted: no" do
    mail = Mail.new(to: "support@example.com", from: "casey@example.com", subject: "Real question", body: "Help please")
    mail["Auto-Submitted"] = "no"

    assert_difference "Ticket.count", 1 do
      receive_inbound_email_from_source(mail.to_s)
    end
  end

  test "a new email lands in the inbox it was sent to" do
    receive_inbound_email_from_mail \
      to: "Billing <billing@example.com>", from: "riley@example.com",
      subject: "Refund", body: "Please refund my order"

    assert_equal inboxes(:billing), Ticket.last.inbox
  end

  test "uses the forwarded-to address when To doesn't match an inbox" do
    mail = Mail.new(to: "team@forwarder.example", from: "riley@example.com", subject: "Invoice", body: "Hi")
    mail["X-Original-To"] = "billing@example.com"
    receive_inbound_email_from_source(mail.to_s)

    assert_equal inboxes(:billing), Ticket.last.inbox
  end

  test "mail to an unknown address goes to the default inbox" do
    receive_inbound_email_from_mail \
      to: "random@example.com", from: "riley@example.com", subject: "Hello", body: "Hi"

    assert_equal inboxes(:support), Ticket.last.inbox
  end
end
