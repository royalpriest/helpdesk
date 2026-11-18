require "test_helper"

class SavedViewsControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as users(:one) }

  test "saves the current filter, tag and search" do
    assert_difference "users(:one).saved_views.count", 1 do
      post saved_views_path, params: { saved_view: { name: "Bugs", filter: "all", tag: "bug", query: "crash" } }
    end
    assert_redirected_to tickets_path(filter: "all", tag: "bug", q: "crash")
  end

  test "rejects a view without a name" do
    assert_no_difference "SavedView.count" do
      post saved_views_path, params: { saved_view: { name: "", filter: "open" } }
    end
  end

  test "lists your views on the inbox" do
    get tickets_path
    assert_select ".saved-views a", "Billing"
  end

  test "deletes your own view but not someone else's" do
    delete saved_view_path(saved_views(:billing_open))
    assert_not SavedView.exists?(saved_views(:billing_open).id)

    other = users(:two).saved_views.create!(name: "Mine", filter: "mine")
    delete saved_view_path(other)
    assert_response :not_found
    assert SavedView.exists?(other.id)
  end
end
