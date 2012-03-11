require 'rails/railtie'
require 'lograge/log_subscriber'

module Lograge
  class Railtie < Rails::Railtie
    initializer :lograge do |app|
      if app.config.log_rage.enabled
        app.config.action_dispatch.rack_cache[:verbose] = false
        require 'lograge/rails_ext/rack/logger'
        Lograge.remove_existing_log_subscriptions
        Lograge::LogSubscriber.attach_to :action_controller
      end
    end
  end
end
