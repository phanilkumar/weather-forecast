class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Add rate limit headers to all responses
  after_action :add_rate_limit_headers

  private

  def add_rate_limit_headers
    # Get current rate limit info from Rack::Attack
    discriminator = "req/ip:#{request.ip}"
    limit_info = Rack::Attack.cache.read("#{discriminator}:limit")

    if limit_info
      response.headers["X-RateLimit-Limit"] = limit_info[:limit].to_s
      response.headers["X-RateLimit-Remaining"] = [ limit_info[:limit] - limit_info[:count], 0 ].max.to_s
      response.headers["X-RateLimit-Reset"] = (Time.now + limit_info[:period]).to_i.to_s
    else
      # Default headers when no rate limit info is available
      response.headers["X-RateLimit-Limit"] = "100"
      response.headers["X-RateLimit-Remaining"] = "100"
      response.headers["X-RateLimit-Reset"] = (Time.now + 5.minutes).to_i.to_s
    end
  end
end
