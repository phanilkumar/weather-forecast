require 'rails_helper'

RSpec.describe Geocoding::NominatimClient do
  it 'returns helpful error for misspelled address (thrivannamalai)', :vcr do
    VCR.use_cassette('geocode/wrong_address_not_found') do
      expect {
        described_class.new.geocode('thrivannamalai')
      }.to raise_error(ArgumentError, /not found/i)
    end
  end
end


