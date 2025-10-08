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
      query = address.to_s.strip
      raise ArgumentError, "Address must be present" if query.empty?

      cache_key = "geocode:#{query.downcase}"
      result = Rails.cache.fetch(cache_key, expires_in: 1.hour) do
        records = ::Geocoder.search(query)
        first = records.first
        first ? build_result(first) : :not_found
      end

      if result == :not_found
        raise ArgumentError, query.length < 3 ?
          "Address too short. Please enter a more specific location." :
          "Location '#{query}' not found. Please check spelling and try again."
      end

      result
    end

    private

    def build_result(first)
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
