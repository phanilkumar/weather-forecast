Geocoder.configure(
  # Use Nominatim (OpenStreetMap)
  lookup: :nominatim,
  # Identify the app per Nominatim usage policy
  http_headers: {
    "User-Agent" => "weather-forecast (test-setup)"
  },
  timeout: 3,
  units: :mi,
  # Cache geocoding results via Rails.cache to reduce upstream calls in dev/prod
  cache: Rails.cache,
  # In test, disable external calls by default; tests should stub requests
  always_raise: Rails.env.test? ? [Geocoder::Error] : [],
  # Basic rate limiting politeness via sleep between requests (dev only)
  # Note: For production, prefer upstream rate limiting + caching
  # (Left at default to avoid slowing dev workflow.)
)


