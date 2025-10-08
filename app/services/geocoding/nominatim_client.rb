module Geocoding
  class NominatimClient
    Result = Struct.new(
      :zip_code,
      :latitude,
      :longitude,
      :city,
      :state,
      :country,
      keyword_init: true
    )

    def geocode(address)
      raise ArgumentError, "address must be present" if address.to_s.strip.empty?

      records = ::Geocoder.search(address)
      first = records.first
      return nil if first.nil?

      data = first.data
      addr = (data && data["address"]) || {}

      zip_code = addr["postcode"] || addr["postal_code"]

      Result.new(
        zip_code: zip_code,
        latitude: first.latitude,
        longitude: first.longitude,
        city: addr["city"] || addr["town"] || addr["village"],
        state: addr["state"],
        country: addr["country"]
      )
    end
  end
end
