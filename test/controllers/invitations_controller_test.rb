require "test_helper"

class InvitationsControllerTest < ActionDispatch::IntegrationTest
  test "an invited agent sets a password and is signed in" do
    user = users(:two)
    token = user.generate_token_for(:invitation)

    get edit_invitation_path(token)
    assert_response :success

    put invitation_path(token), params: { password: "new-password", password_confirmation: "new-password" }
    assert_redirected_to root_path
    assert user.reload.authenticate("new-password")
  end

  test "the link stops working once used" do
    user = users(:two)
    token = user.generate_token_for(:invitation)
    user.update!(password: "something-else")

    get edit_invitation_path(token)
    assert_redirected_to new_session_path
  end

  test "a bad link is rejected" do
    get edit_invitation_path("nope")
    assert_redirected_to new_session_path
  end
end
