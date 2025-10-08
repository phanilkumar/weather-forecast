# frozen_string_literal: true

# Rack::Attack configuration for rate limiting
# Moderate rate limits - not too strict, not too permissive

class Rack::Attack
  # Use Rails cache store for rate limiting
  Rack::Attack.cache.store = Rails.cache

  # Allow requests from localhost in development
  if Rails.env.development?
    Rack::Attack.safelist("allow-localhost") do |req|
      req.ip == "127.0.0.1" || req.ip == "::1"
    end
  end

  # Allow health check endpoint
  Rack::Attack.safelist("allow-health-check") do |req|
    req.path == "/up"
  end

  # General rate limiting - moderate limits
  # 100 requests per 5 minutes per IP
  throttle("req/ip", limit: 100, period: 5.minutes) do |req|
    req.ip unless req.path == "/up"
  end

  # Stricter limits for forecast endpoints (weather API calls are expensive)
  # 20 requests per minute per IP for forecast creation/updates
  throttle("forecast/ip", limit: 20, period: 1.minute) do |req|
    if req.path == "/forecast" && (req.post? || req.patch?)
      req.ip
    end
  end

  # Rate limit rapid successive requests - this is the one we'll test
  # 5 requests per 10 seconds per IP
  throttle("rapid/ip", limit: 5, period: 10.seconds) do |req|
    req.ip unless req.path == "/up"
  end

  # Use default Rack::Attack response for now
  # Custom response can be added later if needed

  # Log rate limit hits
  ActiveSupport::Notifications.subscribe("rack.attack") do |name, start, finish, request_id, payload|
    req = payload[:request]
    Rails.logger.warn "[Rack::Attack] #{payload[:match_discriminator]} #{req.ip} #{req.request_method} #{req.fullpath}"
  end
end

# Rack::Attack middleware is configured in application.rb
