require 'rails_helper'

RSpec.describe WeatherProviders::OpenWeatherMapClient do
  it 'fetches current and forecast with Faraday' do
    stub = Faraday.new do |b|
      b.adapter :test do |stubs|
        stubs.get('https://api.openweathermap.org/data/2.5/weather') { |env| [ 200, {}, { main: { temp: 72, feels_like: 70 }, weather: [ { main: 'Clear', description: 'clear sky' } ], wind: { speed: 3 } }.to_json ] }
        stubs.get('https://api.openweathermap.org/data/2.5/forecast') { |env| [ 200, {}, { list: [] }.to_json ] }
      end
    end

    client = described_class.new(http_client: stub)
    data = client.fetch_current_and_5day(lat: 1.0, lon: 2.0)
    expect(data[:current]).to be_a(Hash)
    expect(data[:forecast]).to be_a(Hash)
  end
end
