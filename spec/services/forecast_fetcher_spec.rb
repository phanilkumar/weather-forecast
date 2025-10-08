require 'rails_helper'

RSpec.describe ForecastFetcher do
  let(:geo) { Geocoding::NominatimClient::Result.new(zip_code: '94043', latitude: 1.0, longitude: 2.0, city: 'MV', state: 'CA', country: 'USA') }

  it 'returns cached result when present' do
    geocoder = instance_double(Geocoding::NominatimClient)
    cache = ForecastCache.new(store: ActiveSupport::Cache::MemoryStore.new)
    cached = { 'zip_code' => '94043', 'current' => { 'temp_f' => 60 } }
    cache.write_by_zip('94043', cached)

    allow(geocoder).to receive(:geocode).and_return(geo)
    fetcher = described_class.new(geocoder: geocoder, cache: cache)

    result, from_cache = fetcher.call('any')
    expect(from_cache).to eq(true)
    expect(result['current']['temp_f']).to eq(60)
  end

  it 'fetches from provider and writes cache on miss' do
    geocoder = instance_double(Geocoding::NominatimClient)
    provider = instance_double(WeatherProviders::OpenWeatherMapClient)
    cache = ForecastCache.new(store: ActiveSupport::Cache::MemoryStore.new)
    normalizer = ForecastNormalizer.new

    allow(geocoder).to receive(:geocode).and_return(geo)
    allow(provider).to receive(:fetch_current_and_5day).and_return({ current: { 'main' => { 'temp' => 61, 'feels_like' => 59, 'humidity' => 40 }, 'weather' => [ { 'main' => 'Clear', 'description' => 'clear sky', 'icon' => '01d' } ], 'wind' => { 'speed' => 2 } }, forecast: { 'list' => [] } })

    fetcher = described_class.new(geocoder: geocoder, provider: provider, cache: cache, normalizer: normalizer)
    result, from_cache = fetcher.call('any')
    expect(from_cache).to eq(false)
    expect(result['zip_code']).to eq('94043')
    expect(cache.fetch_by_zip('94043')).to be_present
  end
end
