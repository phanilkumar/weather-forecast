require 'rails_helper'

RSpec.describe "Forecasts update", type: :request do
  describe "PATCH /forecast" do
    it "redirects to root when missing params" do
      patch forecast_path
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to match(/Missing location/)
    end

    it "renders show when address provided and fetch succeeds" do
      allow(Geocoding::NominatimClient).to receive(:new).and_return(
        instance_double(Geocoding::NominatimClient,
          geocode: Geocoding::NominatimClient::Result.new(zip_code: '94043', latitude: 1.0, longitude: 2.0, city: 'MV', state: 'CA', country: 'USA'))
      )
      allow_any_instance_of(WeatherProviders::OpenWeatherMapClient).to receive(:fetch_current_and_5day).and_return({ current: { 'main' => { 'temp' => 61, 'feels_like' => 59, 'humidity' => 40 }, 'weather' => [ { 'main' => 'Clear', 'description' => 'clear sky', 'icon' => '01d' } ], 'wind' => { 'speed' => 2 } }, forecast: { 'list' => [] } })

      patch forecast_path, params: { address: "Mountain View" }
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("5-Day Forecast")
    end

    it "redirects with error when geocoder raises" do
      bad_geo = instance_double(Geocoding::NominatimClient)
      allow(bad_geo).to receive(:geocode).and_raise(ArgumentError, "bad address")
      allow(Geocoding::NominatimClient).to receive(:new).and_return(bad_geo)
      patch forecast_path, params: { address: "xx" }
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq("bad address")
    end
  end
end
