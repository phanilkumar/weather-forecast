require 'rails_helper'

RSpec.describe ForecastNormalizer do
  it 'normalizes OWM payload with daily hi/lo aggregation' do
    geo = Geocoding::NominatimClient::Result.new(zip_code: '94043', latitude: 1.0, longitude: 2.0, city: 'MV', state: 'CA', country: 'USA')
    now = Time.utc(2025, 1, 1, 12)
    list = [
      { 'dt' => now.to_i, 'main' => { 'temp' => 60 }, 'weather' => [ { 'main' => 'Clear', 'icon' => '01d' } ] },
      { 'dt' => (now + 3.hours).to_i, 'main' => { 'temp' => 50 }, 'weather' => [ { 'main' => 'Clear', 'icon' => '01d' } ] }
    ]
    payload = {
      current: { 'main' => { 'temp' => 61, 'feels_like' => 59, 'humidity' => 40 }, 'weather' => [ { 'main' => 'Clear', 'description' => 'clear sky', 'icon' => '01d' } ], 'wind' => { 'speed' => 2 } },
      forecast: { 'list' => list }
    }

    norm = described_class.new.from_open_weather_map(geo: geo, payload: payload)
    expect(norm.current[:temp_f]).to eq(61)
    expect(norm.daily.first[:high_f]).to eq(60)
    expect(norm.daily.first[:low_f]).to eq(50)
    expect(norm.provider).to eq('OWM')
  end
end
