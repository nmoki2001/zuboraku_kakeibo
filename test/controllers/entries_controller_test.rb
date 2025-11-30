require "test_helper"

class EntriesControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get entries_new_url
    assert_response :success
  end
end
