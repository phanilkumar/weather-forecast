class ForecastFetcher
  def initialize(
    geocoder: Geocoding::NominatimClient.new,
    provider: WeatherProviders::OpenWeatherMapClient.new,
    cache: ForecastCache.new,
    normalizer: ForecastNormalizer.new
  )
    @geocoder = geocoder
    @provider = provider
    @cache = cache
    @normalizer = normalizer
  end

  def call(address)
    geo = @geocoder.geocode(address)
    raise ArgumentError, "Address could not be geocoded" unless geo

    if geo.zip_code.present?
      cached = @cache.fetch_by_zip(geo.zip_code)
      return [cached, true] if cached
    end

    raw = @provider.fetch_current_and_5day(lat: geo.latitude, lon: geo.longitude)
    normalized = @normalizer.from_open_weather_map(geo: geo, payload: raw)
    structured = {
      "location_name" => normalized.location_name,
      "zip_code" => normalized.zip_code,
      "latitude" => normalized.latitude,
      "longitude" => normalized.longitude,
      "current" => normalized.current,
      "daily" => normalized.daily,
      "provider" => normalized.provider
    }

    if normalized.zip_code.present?
      structured = @cache.write_by_zip(normalized.zip_code, structured)
    end

    [structured, false]
  end
end
