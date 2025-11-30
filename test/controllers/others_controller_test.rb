require "test_helper"

class OthersControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get others_show_url
    assert_response :success
  end
end
