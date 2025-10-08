module ForecastsHelper
  def format_temperature(temp)
    return "N/A" if temp.nil?
    value = temp.respond_to?(:round) ? temp.round : temp
    "#{value}°F"
  end

  def format_wind(wind_mph)
    return "N/A" if wind_mph.nil?
    value = wind_mph.respond_to?(:round) ? wind_mph.round : wind_mph
    "#{value} mph"
  end

  def format_humidity(humidity)
    return "N/A" if humidity.nil?
    "#{humidity}%"
  end

  # Maps OpenWeatherMap icon codes to their image URLs. Falls back to a simple emoji if missing.
  def weather_icon(icon_code, alt: "")
    return content_tag(:span, "⛅", class: "weather-icon", aria: { hidden: true }) if icon_code.blank?
    # OWM icon CDN pattern: https://openweathermap.org/img/wn/{icon}@2x.png
    image_tag("https://openweathermap.org/img/wn/#{icon_code}@2x.png", alt: alt.presence || "Weather icon", class: "weather-icon", width: 50, height: 50, loading: "lazy")
  end
end
