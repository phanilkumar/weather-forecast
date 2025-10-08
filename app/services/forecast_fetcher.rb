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
      if cached
        Rails.logger.info("Cache hit for ZIP: #{geo.zip_code}")
        return [ cached, true ]
      else
        Rails.logger.info("Cache miss for ZIP: #{geo.zip_code}")
      end
    end

    # Try lat/lon-based cache when ZIP is not present or cache missed
    latlon_cached = @cache.fetch_by_latlon(geo.latitude, geo.longitude)
    if latlon_cached
      Rails.logger.info("Cache hit for lat/lon: #{geo.latitude},#{geo.longitude}")
      return [ latlon_cached, true ]
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
    else
      structured = @cache.write_by_latlon(normalized.latitude, normalized.longitude, structured)
    end

    [ structured, false ]
  end
end
