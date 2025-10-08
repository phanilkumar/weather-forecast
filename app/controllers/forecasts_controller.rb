class ForecastsController < ApplicationController
  def new
  end

  def create
    address = params[:address].to_s
    if address.strip.empty?
      flash.now[:alert] = "Please enter an address"
      return render :new, status: :unprocessable_content
    end

    begin
      structured, from_cache = ForecastFetcher.new.call(address)
      @forecast = ForecastPresenter.new(structured, from_cache: from_cache)
      render :show
    rescue ArgumentError => e
      flash.now[:alert] = e.message
      render :new, status: :unprocessable_content
    rescue => e
      Rails.logger.error("Fetch forecast error: #{e.class}: #{e.message}")
      flash.now[:alert] = "Unable to retrieve forecast right now. Please try again."
      render :new, status: :service_unavailable
    end
  end

  def update
    # Refresh forecast using provided params. Prefer explicit address, then zip, then lat/lon.
    address = params[:address].to_s
    zip = params[:zip_code].presence || params[:zip].presence
    lat = params[:latitude].presence || params[:lat].presence
    lon = params[:longitude].presence || params[:lon].presence

    resolved_address = if address.present?
      address
    elsif zip.present?
      zip
    elsif lat.present? && lon.present?
      "#{lat}, #{lon}"
    else
      # No context provided; redirect back to new with an alert
      flash[:alert] = "Missing location details to refresh forecast."
      return redirect_to root_path
    end

    begin
      structured, from_cache = ForecastFetcher.new.call(resolved_address)
      @forecast = ForecastPresenter.new(structured, from_cache: from_cache)
      render :show
    rescue ArgumentError => e
      flash[:alert] = e.message
      redirect_to root_path
    rescue => e
      Rails.logger.error("Refresh forecast error: #{e.class}: #{e.message}")
      flash[:alert] = "Unable to refresh forecast right now. Please try again."
      redirect_to root_path
    end
  end
end
