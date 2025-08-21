require 'test_helper'

class WeatherServiceTest < ActiveSupport::TestCase
  setup do
    @service = WeatherService.new
    Rails.cache.clear
  end

  test "should return error for blank address" do
    result = @service.get_weather_by_address("")
    assert result[:error].present?
    assert_equal "Address cannot be blank", result[:error]
  end

  test "should generate cache key with country and postal code" do
    # This would normally require mocking the API response
    # For now, we'll test the cache key generation logic
    cache_key = @service.send(:generate_cache_key, "US", "10001", 40.7128, -74.0060)
    assert_equal "weather:US:10001", cache_key
  end

  test "should fallback to coordinates for cache key when postal code not available" do
    cache_key = @service.send(:generate_cache_key, nil, nil, 40.7128, -74.0060)
    assert_equal "weather:40.71:-74.01", cache_key
  end

  test "should extract US postal code from address" do
    postal_code = @service.send(:extract_postal_code, "123 Main St, New York, NY 10001")
    assert_equal "10001", postal_code
  end

  test "should extract UK postal code from address" do
    postal_code = @service.send(:extract_postal_code, "10 Downing Street, London SW1A 2AA")
    assert_equal "SW1A 2AA", postal_code
  end

  test "should convert wind degrees to direction" do
    assert_equal "N", @service.send(:wind_direction, 0)
    assert_equal "E", @service.send(:wind_direction, 90)
    assert_equal "S", @service.send(:wind_direction, 180)
    assert_equal "W", @service.send(:wind_direction, 270)
  end
end