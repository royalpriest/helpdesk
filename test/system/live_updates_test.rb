require "application_system_test_case"

class LiveUpdatesTest < ApplicationSystemTestCase
  include ActiveJob::TestHelper

  test "a new customer message shows up without reloading the page" do
    ticket = tickets(:login)
    sign_in_as users(:one)
    click_on "Can't log in"
    assert_selector "turbo-cable-stream-source[connected]", visible: :all

    perform_enqueued_jobs do
      ticket.add_customer_message!(body: "Any update on this?")
    end

    assert_selector ".message.customer", text: "Any update on this?"
  end
end
