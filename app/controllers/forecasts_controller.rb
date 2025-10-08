class ForecastsController < ApplicationController
  def new
  end

  def create
    address = params[:address].to_s
    if address.strip.empty?
      flash.now[:alert] = "Please enter an address"
      return render :new, status: :unprocessable_entity
    end

    begin
      structured, from_cache = ForecastFetcher.new.call(address)
      @forecast = ForecastPresenter.new(structured, from_cache: from_cache)
      render :show
    rescue ArgumentError => e
      flash.now[:alert] = e.message
      render :new, status: :unprocessable_entity
    rescue => e
      Rails.logger.error("Fetch forecast error: #{e.class}: #{e.message}")
      flash.now[:alert] = "Unable to retrieve forecast right now. Please try again."
      render :new, status: :service_unavailable
    end
  end
end
