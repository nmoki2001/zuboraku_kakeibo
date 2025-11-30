require "test_helper"

class AnalysisControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get analysis_show_url
    assert_response :success
  end
end
