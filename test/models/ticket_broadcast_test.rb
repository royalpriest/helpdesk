require "test_helper"

class TicketBroadcastTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  test "a new customer message refreshes the inbox and the ticket page" do
    ticket = tickets(:login)

    perform_enqueued_jobs do
      ticket.add_customer_message!(body: "Any news?")
    end

    assert_turbo_stream_broadcasts :tickets
    assert_turbo_stream_broadcasts ticket
  end

  test "a new ticket refreshes the inbox" do
    perform_enqueued_jobs do
      customers(:jordan).tickets.create!(subject: "Brand new")
    end

    assert_turbo_stream_broadcasts :tickets
  end
end
