%w[weather.cache_hit weather.cache_miss weather.cache_write].each do |name|
  ActiveSupport::Notifications.subscribe(name) do |*args|
    event = ActiveSupport::Notifications::Event.new(*args)
    Rails.logger.info("[metrics] #{event.name} #{event.payload.inspect}")
  end
end

# Optional: observe Rails cache events (debug-level)
%w[cache_read.active_support cache_write.active_support cache_fetch_hit.active_support].each do |name|
  ActiveSupport::Notifications.subscribe(name) do |*args|
    event = ActiveSupport::Notifications::Event.new(*args)
    Rails.logger.debug("[rails-cache] #{event.name} #{event.payload.inspect}")
  end
end
