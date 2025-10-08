require "rails_helper"

RSpec.describe ForecastsHelper, type: :helper do
  describe "#format_temperature" do
    it "returns N/A for nil" do
      expect(helper.format_temperature(nil)).to eq("N/A")
    end

    it "rounds numeric and appends °F" do
      expect(helper.format_temperature(55.6)).to eq("56°F")
    end

    it "handles string values" do
      expect(helper.format_temperature("55")).to eq("55°F")
    end
  end

  describe "#format_wind" do
    it "returns N/A for nil" do
      expect(helper.format_wind(nil)).to eq("N/A")
    end

    it "rounds numeric and appends mph" do
      expect(helper.format_wind(3.4)).to eq("3 mph")
    end
  end

  describe "#format_humidity" do
    it "returns N/A for nil" do
      expect(helper.format_humidity(nil)).to eq("N/A")
    end

    it "appends percent" do
      expect(helper.format_humidity(45)).to eq("45%")
    end
  end

  describe "#weather_icon" do
    it "returns emoji fallback for blank icon" do
      html = helper.weather_icon("")
      expect(html).to include("⛅")
    end

    it "returns img tag for icon code" do
      html = helper.weather_icon("01d")
      expect(html).to include("openweathermap.org/img/wn/01d@2x.png")
      expect(html).to include("alt=\"Weather icon\"")
    end
  end
end
