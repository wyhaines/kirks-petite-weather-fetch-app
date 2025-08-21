class WeatherService
  CACHE_DURATION = 30.minutes

  def initialize = @api = OpenweatherApi.new

  def get_weather_by_address(address)
    return { error: "Address cannot be blank" } if address.blank?

    location_data = @api.geocode(address)
    
    if location_data.nil? || location_data.empty?
      return { error: "Unable to find location for the given address" }
    end

    location = location_data.first
    lat = location['lat']
    lon = location['lon']
    country = location['country']
    postal_code = extract_postal_code(address)
    
    cache_key = generate_cache_key(country, postal_code, lat, lon)
    
    cached_data = Rails.cache.read(cache_key)
    
    if cached_data
      return cached_data.merge(
        from_cache: true,
        cache_key: cache_key
      )
    end

    weather_data = fetch_weather_data(lat, lon, location)
    
    Rails.cache.write(cache_key, weather_data, expires_in: CACHE_DURATION)
    
    weather_data.merge(
      from_cache: false,
      cache_key: cache_key
    )
  rescue OpenweatherApi::ApiError => e
    { error: e.message }
  rescue StandardError => e
    Rails.logger.error "Weather service error: #{e.message}"
    { error: "An unexpected error occurred. Please try again later." }
  end

  def fetch_weather_data(lat, lon, location)
    data = @api.onecall_data(lat, lon)
    
    current = data['current']
    daily = data['daily']
    
    {
      location: {
        name: location['name'],
        state: location['state'],
        country: location['country'],
        lat: lat,
        lon: lon
      },
      current: {
        temperature: current['temp'].round,
        feels_like: current['feels_like'].round,
        temp_min: daily.first['temp']['min'].round,
        temp_max: daily.first['temp']['max'].round,
        humidity: current['humidity'],
        pressure: current['pressure'],
        description: current['weather'].first['description'].capitalize,
        icon: current['weather'].first['icon'],
        wind_speed: current['wind_speed'].round,
        wind_direction: wind_direction(current['wind_deg']),
        sunrise: Time.at(current['sunrise']).strftime("%I:%M %p"),
        sunset: Time.at(current['sunset']).strftime("%I:%M %p")
      },
      forecast: process_forecast(daily),
      fetched_at: Time.current
    }
  end

  def process_forecast(daily_data)
    daily_data.take(5).map do |day|
      {
        date: Time.at(day['dt']).strftime("%A, %B %d"),
        high: day['temp']['max'].round,
        low: day['temp']['min'].round,
        avg_humidity: day['humidity'].round,
        weather: day['weather'].first['description'].capitalize,
        icon: day['weather'].first['icon']
      }
    end
  end

  def extract_postal_code(address)
    patterns = [
      /\b\d{5}(-\d{4})?\b/,
      /\b[A-Z]{1,2}\d{1,2}[A-Z]?\s?\d[A-Z]{2}\b/i,
      /\b[A-Z]\d[A-Z]\s?\d[A-Z]\d\b/i,
      /\b\d{4,6}\b/
    ]
    
    patterns.each do |pattern|
      match = address.match(pattern)
      return match[0] if match
    end
    
    nil
  end

  DIRECTIONS = %w[N NNE NE ENE E ESE SE SSE S SSW SW WSW W WNW NW NNW]
  def wind_direction(degrees) = degrees ? DIRECTIONS[((degrees + 11.25) / 22.5).floor % 16] : 'N/A'
  def generate_cache_key(country, postal_code, lat, lon) =  (country.present? && postal_code.present?) ? "weather:#{country}:#{postal_code}" : "weather:#{lat.round(2)}:#{lon.round(2)}"

end
