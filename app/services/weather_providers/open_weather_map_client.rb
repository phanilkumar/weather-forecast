module WeatherProviders
  class OpenWeatherMapClient
    class Error < StandardError; end
    class Unauthorized < Error; end

    def initialize(http_client: default_http)
      @http = http_client
      @api_key = ENV.fetch("OWM_API_KEY")
      @base_url = "https://api.openweathermap.org/data/2.5"
    end

    def fetch_current_and_5day(lat:, lon:)
      current = get_json("#{@base_url}/weather", lat: lat, lon: lon, units: "imperial", appid: @api_key)
      forecast = get_json("#{@base_url}/forecast", lat: lat, lon: lon, units: "imperial", appid: @api_key)
      { current: current, forecast: forecast }
    end

    private

    def get_json(url, params)
      response = @http.get(url, params)
      unless response.success?
        snippet = safe_snippet(response)
        raise Error, "HTTP #{response.status}: #{snippet}"
      end
      JSON.parse(response.body)
    rescue Faraday::UnauthorizedError
      raise Unauthorized, "HTTP 401: unauthorized"
    rescue Faraday::ClientError => e
      status = (e.response && e.response[:status]) || 'client_error'
      raise Error, "HTTP #{status}: #{e.message}"
    rescue JSON::ParserError => e
      raise Error, "Invalid JSON response: #{e.message}"
    end

    def safe_snippet(response)
      body = response&.body.to_s
      body[0, 200]
    rescue
      ""
    end

    def default_http
      Faraday.new do |f|
        f.request :retry, max: 2, interval: 0.2, interval_randomness: 0.2, backoff_factor: 2,
          retry_statuses: [ 429, 500, 502, 503, 504 ]
        f.options.timeout = 5
        f.options.open_timeout = 3
        f.response :raise_error
        f.adapter Faraday.default_adapter
      end
    end
  end
end
