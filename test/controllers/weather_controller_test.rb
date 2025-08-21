require "test_helper"

class WeatherControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get root_url
    assert_response :success
    assert_select "h1", "Kirk's Petite Weather Fetch Tool"
  end

  test "should return error for blank address" do
    post weather_search_url, params: { address: "" }, as: :turbo_stream
    assert_response :success
    assert_match "Please enter an address", response.body
  end

  test "should handle search with valid address" do
    # This would normally require mocking the API
    # For integration testing, you'd need a valid API key
    post weather_search_url, params: { address: "New York, NY" }, as: :turbo_stream
    assert_response :success
  end
end
