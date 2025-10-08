class ForecastCache
  TTL = 30.minutes
  STALE_TTL = 6.hours

  def initialize(store: Rails.cache)
    @store = store
  end

  # Basic read with stale fallback
  def fetch_by_zip(zip_code)
    @store.read(cache_key(zip_code)) || @store.read(stale_cache_key(zip_code))
  end

  def fetch_by_latlon(lat, lon)
    @store.read(latlon_key(lat, lon)) || @store.read(stale_latlon_key(lat, lon))
  end

  # Write fresh value and also maintain a longer-lived stale copy
  def write_by_zip(zip_code, value)
    payload = value.merge("cached_at" => Time.current)
    @store.write(cache_key(zip_code), payload, expires_in: TTL)
    @store.write(stale_cache_key(zip_code), payload, expires_in: STALE_TTL)
    payload
  end

  def write_by_latlon(lat, lon, value)
    payload = value.merge("cached_at" => Time.current)
    @store.write(latlon_key(lat, lon), payload, expires_in: TTL)
    @store.write(stale_latlon_key(lat, lon), payload, expires_in: STALE_TTL)
    payload
  end

  # Stampede-safe fetch/write using Rails.cache.fetch with race_condition_ttl
  # The caller supplies the block that computes the fresh value
  def fetch_or_store_by_zip(zip_code, race_condition_ttl: 10.seconds)
    @store.fetch(cache_key(zip_code), expires_in: TTL, race_condition_ttl: race_condition_ttl) do
      value = yield
      # Mirror into stale store as well
      @store.write(stale_cache_key(zip_code), value, expires_in: STALE_TTL)
      value
    end
  end

  def cache_key(zip_code)
    "weather:#{zip_code}"
  end

  def stale_cache_key(zip_code)
    "weather:stale:#{zip_code}"
  end

  def latlon_key(lat, lon)
    "weather:lat:#{lat.round(3)}:lon:#{lon.round(3)}"
  end

  def stale_latlon_key(lat, lon)
    "weather:stale:lat:#{lat.round(3)}:lon:#{lon.round(3)}"
  end
end
