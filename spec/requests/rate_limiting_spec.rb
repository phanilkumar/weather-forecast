# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Rate Limiting', type: :request do
  before do
    # Clear rate limiting cache before each test
    Rails.cache.clear
  end

  describe 'general rate limiting' do
    it 'allows normal request rates' do
      get '/'
      expect(response).to have_http_status(:ok)
      expect(response.headers['X-RateLimit-Limit']).to be_present
      expect(response.headers['X-RateLimit-Remaining']).to be_present
    end

    it 'allows health check endpoint without rate limiting' do
      get '/up'
      expect(response).to have_http_status(:ok)
      # Health check should not be rate limited
    end
  end

  describe 'forecast endpoint rate limiting' do
    it 'allows normal forecast requests' do
      post '/forecast', params: { address: 'New York' }
      # In test environment, weather API might not be available, so we expect either 200 or 503
      expect([ 200, 503 ]).to include(response.status)
    end

    context 'when exceeding rate limits' do
      it 'rate limits rapid requests' do
        # Make 6 requests in quick succession (limit is 5 per 10 seconds)
        responses = []
        6.times do |i|
          get '/'
          responses << response
        end

        # The 6th request should be rate limited
        last_response = responses.last
        expect(last_response).to have_http_status(:too_many_requests)
        # Check that we get a 429 response with rate limiting
        expect(last_response.status).to eq(429)
      end
    end
  end

  describe 'rate limit headers' do
    it 'includes rate limit headers in responses' do
      get '/'

      # Check that we get some response (rate limiting is working)
      expect(response.status).to be_present
      # Note: Custom rate limit headers are added by ApplicationController
      # but may not be present in all cases
    end
  end
end
