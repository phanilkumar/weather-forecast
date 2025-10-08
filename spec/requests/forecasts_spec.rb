require 'rails_helper'

RSpec.describe "Forecasts", type: :request do
  before do
    # Clear rate limiting cache before each test to prevent interference
    Rails.cache.clear
  end
  describe "GET /" do
    it "renders new form" do
      get root_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Enter Address")
    end
  end

  describe "POST /forecast" do
    it "shows error for blank address" do
      post forecast_path, params: { address: "   " }
      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include("Please enter an address")
    end

    it "renders show on success" do
      geo = Geocoding::NominatimClient::Result.new(zip_code: '94043', latitude: 1.0, longitude: 2.0, city: 'MV', state: 'CA', country: 'USA')
      allow(Geocoding::NominatimClient).to receive(:new).and_return(instance_double(Geocoding::NominatimClient, geocode: geo))
      allow_any_instance_of(WeatherProviders::OpenWeatherMapClient).to receive(:fetch_current_and_5day).and_return({ current: { 'main' => { 'temp' => 61, 'feels_like' => 59, 'humidity' => 40 }, 'weather' => [ { 'main' => 'Clear', 'description' => 'clear sky', 'icon' => '01d' } ], 'wind' => { 'speed' => 2 } }, forecast: { 'list' => [] } })

      post forecast_path, params: { address: "1600 Amphitheatre" }
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("5-Day Forecast")
    end
  end
end
