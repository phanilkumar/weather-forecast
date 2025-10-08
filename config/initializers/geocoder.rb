Geocoder.configure(
  # Use Nominatim (OpenStreetMap)
  lookup: :nominatim,
  # Identify the app per Nominatim usage policy
  http_headers: {
    "User-Agent" => "weather-forecast (#{ENV.fetch('ADMIN_EMAIL', 'admin@example.com')})"
  },
  timeout: ENV.fetch("GEOCODER_TIMEOUT", "3").to_i,
  units: :mi,
  # Cache geocoding results via Rails.cache to reduce upstream calls in dev/prod
  cache: Rails.cache,
  cache_prefix: "geocoder:",  # Namespace cache keys
  # In test, disable external calls by default; tests should stub requests
  always_raise: Rails.env.test? ? [ Geocoder::Error ] : [],
  # Nominatim-specific settings
  nominatim: {
    host: ENV.fetch("NOMINATIM_HOST", "nominatim.openstreetmap.org"),  # Explicit host
    timeout: ENV.fetch("NOMINATIM_TIMEOUT", "3").to_i     # Provider-specific timeout
  },
  # Use HTTPS (Nominatim supports it)
  use_https: true,
  # Language preference
  language: :en,
  # Logging (helpful for debugging)
  logger: Rails.env.production? ? Logger.new(nil) : Rails.logger
  # Basic rate limiting politeness via sleep between requests (dev only)
  # Note: For production, prefer upstream rate limiting + caching
  # (Left at default to avoid slowing dev workflow.)
)
