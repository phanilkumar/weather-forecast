# Weather Forecast (Rails 8)

Single GitHub link (code + README + tests):

- Repository: [weather-forecast](https://github.com/phanilkumar/weather-forecast)

## Overview

Rails 8 application that accepts a free-form address, geocodes it to latitude/longitude and postal code (ZIP/PIN), fetches current weather and 5‑day forecast from OpenWeatherMap, normalizes the data for display, and caches the result for 30 minutes by ZIP (with lat/lon fallback). A visible badge indicates cached results.

## Key Features

- Address input → geocoding via Nominatim (OpenStreetMap)
- Weather provider: OpenWeatherMap (current + 5‑day)
- Caching: 30 minutes by ZIP; fallback to rounded lat/lon; stale fallback window
- Cache indicator badge on the results page
- Bootstrap UI via cssbundling-rails (no CDN dependencies)
- Importmap-pinned Bootstrap/Popper (vendored, offline-capable)
- Robust error handling (invalid key, geocode failures, JSON parse)
- Unit and request specs using RSpec, WebMock, and VCR cassettes

## Architecture & Object Decomposition

Top-level flow (Controller → Services → Presenter):

```
ForecastsController
  ├─ uses ForecastFetcher#call(address)
  │    ├─ Geocoding::NominatimClient#geocode
  │    ├─ ForecastCache (fetch_by_zip / fetch_by_latlon)
  │    ├─ WeatherProviders::OpenWeatherMapClient#fetch_current_and_5day
  │    └─ ForecastNormalizer#from_open_weather_map
  └─ ForecastPresenter (view-friendly formatting & cache badge)
```

Responsibilities:

- Geocoding::NominatimClient: address → lat/lon/ZIP/city/state/country
  - Caches geocoding results (success and not-found) for 1 hour
  - Returns helpful errors: too-short input or not-found (typos)

- WeatherProviders::OpenWeatherMapClient: calls OWM with retries/timeouts
  - Raises Unauthorized on 401; includes detailed error snippets for other failures

- ForecastNormalizer: converts OWM payload into consistent schema
  - Aggregates 3‑hour blocks to daily hi/lo; skips partial current day entries

- ForecastCache: 30‑minute TTL (+ stale 6‑hour fallback)
  - Keys: `weather:ZIP` and `weather:lat:<lat>:lon:<lon>` (rounded)
  - Stampede protection via race_condition_ttl for compute blocks
  - Emits `weather.cache_*` metrics via ActiveSupport::Notifications

- ForecastFetcher: orchestration and logging of cache HIT/MISS

- ForecastPresenter: formats data for UI and exposes cache indicator

Design Patterns used:

- Service Object pattern for each integration/core responsibility
- Strategy-style provider client (pluggable if adding more providers)
- Presenter for view concerns and cache badge logic

## Scalability & Resilience Considerations

- Caching: Redis in production; MemoryStore in development
- Stampede control: race_condition_ttl; stale fallback window to serve older data
- Retries/Timeouts: Faraday retry middleware; short timeouts to bound latency
- Observability: cache hit/miss/write instrumented; structured logs
- Background jobs (optional): Solid Queue-ready job shown in documentation for optimistic UX

## Naming & Code Quality

- Descriptive, domain-oriented class and method names
- Encapsulation: small, single-responsibility methods & classes
- Code reuse: normalization and cache helpers are shared; no duplication
- Tests: RSpec unit + request integration; VCR cassettes for HTTP integration

## Setup

Prerequisites:

- Ruby 3.2.2
- Rails 8.0.3
- Node/Yarn (for cssbundling-rails) – installed by the css:install task
- PostgreSQL (development/production); SQLite used for test to avoid DB setup

Install:

```bash
git clone https://github.com/phanilkumar/weather-forecast.git
cd weather-forecast
bundle install

# Install Bootstrap build pipeline
bin/rails css:install:bootstrap

# Prepare DBs (development uses Postgres; update config/database.yml if needed)
bin/rails db:prepare
```

Environment:

```bash
# OpenWeatherMap API key (required at runtime)
echo "OWM_API_KEY=your_real_key" > .env
```

Run:

```bash
# Start dev server with CSS watcher (Foreman loads .env)
bin/dev

# Or start Rails server directly (ensure OWM_API_KEY is in ENV)
bin/rails s
```

## Usage

1) Open `http://localhost:3000`.
2) Enter an address (e.g., "Mountain View, CA" or a PIN/ZIP like "94043").
3) First request (cache miss) may take ~1s due to external API; subsequent requests (same ZIP) are instant with a cache badge.

## Caching Strategy

- Primary key: by ZIP (`weather:<zip>`)
- Fallback key: rounded lat/lon when ZIP missing
- TTL: 30 minutes for fresh cache; stale copy for 6 hours
- Cache indicator shown on results; metrics emitted for HIT/MISS/WRITE

## Error Handling

- Geocoding: typo/too-short inputs raise user-friendly errors; failures are cached briefly to avoid repeated slow misses
- Weather provider: Unauthorized (401) raises explicit error; other HTTP errors include body snippets for context
- Defensive JSON parsing with clear error surfacing

## Testing

Run all specs:

```bash
bundle exec rspec
```

HTTP integration tests (VCR):

- Success and failure cassettes under `spec/cassettes/owm/*`
- Geocoding misspelling cassette under `spec/cassettes/geocode/*`

Record success cassettes (requires real key):

```bash
export OWM_API_KEY=your_real_key
VCR_RECORD=all bundle exec rspec spec/services/weather_providers/open_weather_map_client_spec.rb:4
```

Re-record or force record:

```bash
VCR_RECORD=all bundle exec rspec
```

Sensitive data is filtered as `<OWM_API_KEY>` in cassettes.

## Security & Privacy

- `.env` is ignored by Git and loaded only in dev/test
- API keys are filtered from VCR cassettes
- CSP meta tag enabled; Rails default security headers in place

## Future Enhancements

- Multiple provider strategies with graceful failover
- Background job UX for cache misses (optimistic loading page)
- Location autocomplete (vendored assets only; no third‑party CDNs)
- Internationalization for user-visible strings

## License

For assessment use.

