class ForecastCache
  TTL = 30.minutes

  def initialize(store: Rails.cache)
    @store = store
  end

  def fetch_by_zip(zip_code)
    @store.read(cache_key(zip_code))
  end

  def write_by_zip(zip_code, value)
    payload = value.merge("cached_at" => Time.current)
    @store.write(cache_key(zip_code), payload, expires_in: TTL)
    payload
  end

  def cache_key(zip_code)
    "weather:#{zip_code}"
  end
end
