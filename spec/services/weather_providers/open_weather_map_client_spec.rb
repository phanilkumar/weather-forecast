require 'rails_helper'

RSpec.describe WeatherProviders::OpenWeatherMapClient do
  it 'records and replays success', :vcr do
    VCR.use_cassette('owm/success_current_and_forecast') do
      client = described_class.new
      data = client.fetch_current_and_5day(lat: 37.422, lon: -122.084)
      expect(data[:current]).to be_a(Hash)
      expect(data[:forecast]).to be_a(Hash)
    end
  end

  it 'records and replays failure (401)', :vcr do
    VCR.use_cassette('owm/failure_unauthorized') do
      # Temporarily force a bad key for this cassette only
      ClimateControl.modify OWM_API_KEY: 'bad_key' do
        client = described_class.new
        expect {
          client.fetch_current_and_5day(lat: 37.422, lon: -122.084)
        }.to raise_error(WeatherProviders::OpenWeatherMapClient::Unauthorized, /401/)
      end
    end
  end
end
