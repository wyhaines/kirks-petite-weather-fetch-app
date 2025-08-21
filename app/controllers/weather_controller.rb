class WeatherController < ApplicationController
  def index = @weather_data = nil

  def search
    address = params[:address]
    
    if address.blank?
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.update('weather-results', 
            partial: 'weather/error', 
            locals: { message: 'Please enter an address' })
        end
      end
      return
    end

    service = WeatherService.new
    @weather_data = service.get_weather_by_address(address)
    
    respond_to do |format|
      format.turbo_stream do
        if @weather_data[:error]
          render turbo_stream: turbo_stream.update('weather-results', 
            partial: 'weather/error', 
            locals: { message: @weather_data[:error] })
        else
          render turbo_stream: turbo_stream.update('weather-results', 
            partial: 'weather/results', 
            locals: { weather_data: @weather_data })
        end
      end
    end
  end
end
