class OpenweatherApi
  include HTTParty
  base_uri 'https://api.openweathermap.org'

  NOT_FOUND_MESSAGE = 'Location not found. Check your spelling or try simplifying your search address.'

  def initialize = @api_key = ENV['OPENWEATHER_API_KEY']

  def geocode(address)
    cleaned_address = address.strip
    
    if !cleaned_address.match(/,\s*[A-Z]{2}$/i) && cleaned_address.match(/,\s*(AL|AK|AZ|AR|CA|CO|CT|DE|FL|GA|HI|ID|IL|IN|IA|KS|KY|LA|ME|MD|MA|MI|MN|MS|MO|MT|NE|NV|NH|NJ|NM|NY|NC|ND|OH|OK|OR|PA|RI|SC|SD|TN|TX|UT|VT|VA|WA|WV|WI|WY)/i)
      cleaned_address += ",US"
    end
    
    options = {
      query: {
        q: cleaned_address,
        limit: 5,
        appid: @api_key
      }
    }
    
    response = OpenweatherApi.get('/geo/1.0/direct', options)
    
    if response.code == 200
      results = response.parsed_response
      
      if results && results.any?
        us_results = results.select { |r| r['country'] == 'US' }
        return us_results.any? ? us_results : results
      else
        if cleaned_address != address
          options[:query][:q] = address
          response = OpenweatherApi.get('/geo/1.0/direct', options)
          return handle_response(response) if response.code == 200 && response.parsed_response&.any?
        end
        
        raise ApiError, NOT_FOUND_MESSAGE
      end
    else
      handle_response(response)
    end
  end

  def onecall_data(lat, lon)
    options = {
      query: {
        lat: lat,
        lon: lon,
        appid: @api_key,
        units: 'imperial',
        exclude: 'minutely'
      }
    }
    
    response = OpenweatherApi.get('/data/3.0/onecall', options)
    handle_response(response)
  end

  def current_weather(lat, lon) = onecall_data(lat, lon)&.fetch('current')
  def forecast(lat, lon) = onecall_data(lat, lon)&.fetch('daily')

  def handle_response(response)
    case response.code
    when 200
      response.parsed_response
    when 401
      raise ApiError, "Invalid API key. Please check your OpenWeather API configuration."
    when 404
      raise ApiError, NOT_FOUND_MESSAGE
    when 429
      raise ApiError, "API rate limit exceeded. This really should not happen."
    else
      raise ApiError, "API request failed: #{response.message}"
    end
  end

  class ApiError < StandardError; end
end
