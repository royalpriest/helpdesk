require "test_helper"

class Portal::RatingsControllerTest < ActionDispatch::IntegrationTest
  test "opening the email link only preselects the rating" do
    get new_portal_ticket_rating_path("jordan-closed-token", rating: "good")

    assert_response :success
    assert_select "input[type=radio][value=good][checked]"
    assert_nil tickets(:closed).reload.rated_at
  end

  test "a customer rates their ticket with a comment" do
    post portal_ticket_rating_path("jordan-closed-token"), params: { ticket: { rating: "bad", rating_comment: "Took a while" } }

    assert_redirected_to portal_ticket_path("jordan-closed-token")
    ticket = tickets(:closed).reload
    assert_equal "bad", ticket.rating
    assert_equal "Took a while", ticket.rating_comment
  end

  test "rejects an unknown rating" do
    post portal_ticket_rating_path("jordan-closed-token"), params: { ticket: { rating: "meh" } }
    assert_nil tickets(:closed).reload.rating
  end

  test "the portal asks closed, unrated tickets for a rating" do
    get portal_ticket_path("jordan-closed-token")
    assert_select ".rating-prompt a", "Tell us how we did"
  end
end
