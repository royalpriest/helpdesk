require "test_helper"
require "capybara/cuprite"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  # Uses Chrome or Chromium from your PATH. Set BROWSER_PATH to point at a different one.
  driven_by :cuprite, screen_size: [ 1400, 1000 ], options: {
    headless: true,
    process_timeout: 20,
    browser_options: { "no-sandbox" => nil }
  }

  def sign_in_as(user, password: "password")
    visit new_session_path
    fill_in "email_address", with: user.email_address
    fill_in "password", with: password
    click_on "Sign in"
    assert_selector "h1", text: "Tickets"
  end
end
