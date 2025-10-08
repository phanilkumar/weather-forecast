require 'rails_helper'

RSpec.describe Geocoding::NominatimClient do
  describe '#geocode' do
    it 'returns structured result for a valid address' do
      record = double('GeocoderResult',
        latitude: 37.422,
        longitude: -122.084,
        data: { 'address' => { 'postcode' => '94043', 'city' => 'Mountain View', 'state' => 'CA', 'country' => 'USA' } }
      )
      expect(Geocoder).to receive(:search).with('1600 Amphitheatre Parkway').and_return([ record ])

      client = described_class.new
      res = client.geocode('1600 Amphitheatre Parkway')

      expect(res.zip_code).to eq('94043')
      expect(res.latitude).to eq(37.422)
      expect(res.longitude).to eq(-122.084)
      expect(res.city).to eq('Mountain View')
      expect(res.state).to eq('CA')
      expect(res.country).to eq('USA')
    end

    it 'returns nil when no results' do
      allow(Geocoder).to receive(:search).and_return([])
      expect(described_class.new.geocode('nowhere')).to be_nil
    end

    it 'raises for blank address' do
      expect { described_class.new.geocode('  ') }.to raise_error(ArgumentError)
    end
  end
end
