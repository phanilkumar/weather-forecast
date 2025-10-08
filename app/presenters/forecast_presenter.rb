class ForecastPresenter
  def initialize(structured_hash, from_cache: false)
    @h = structured_hash || {}
    @from_cache = from_cache
  end

  def from_cache?
    !!@from_cache
  end

  def cached_at
    t = @h["cached_at"]
    return unless t
    Time.parse(t.to_s) rescue t
  end

  def location_name
    @h["location_name"]
  end

  def zip_code
    @h["zip_code"]
  end

  def current
    @h["current"] || {}
  end

  def daily
    @h["daily"] || []
  end

  def provider
    @h["provider"]
  end
end
