class ForecastNormalizer
  Normalized = Struct.new(
    :location_name,
    :zip_code,
    :latitude,
    :longitude,
    :current,
    :daily,
    :provider,
    keyword_init: true
  )

  def from_open_weather_map(geo:, payload:)
    current = payload.fetch(:current)
    forecast = payload.fetch(:forecast)

    normalized_current = {
      temp_f: current.dig("main", "temp"),
      feels_like_f: current.dig("main", "feels_like"),
      humidity: current.dig("main", "humidity"),
      wind_mph: current.dig("wind", "speed"),
      conditions: current.dig("weather", 0, "main"),
      description: current.dig("weather", 0, "description"),
      icon: current.dig("weather", 0, "icon"),
      fetched_at: Time.current
    }

    # Aggregate 3-hour blocks into per-day hi/lo + representative condition
    grouped = forecast.fetch("list", []).group_by { |e| Time.at(e["dt"]).to_date }
    daily = grouped.map do |date, entries|
      temps = entries.map { |e| e.dig("main", "temp") }.compact
      hi = temps.max
      lo = temps.min
      primary = entries.first
      {
        date: date,
        high_f: hi,
        low_f: lo,
        conditions: primary.dig("weather", 0, "main"),
        icon: primary.dig("weather", 0, "icon")
      }
    end.sort_by { |d| d[:date] }

    Normalized.new(
      location_name: compose_location_name(geo),
      zip_code: geo.zip_code,
      latitude: geo.latitude,
      longitude: geo.longitude,
      current: normalized_current,
      daily: daily,
      provider: "OWM"
    )
  end

  private

  def compose_location_name(geo)
    [ geo.city, geo.state, geo.country ].compact.join(", ")
  end
end
