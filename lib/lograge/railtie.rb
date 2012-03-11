require 'rails/railtie'
require 'lograge/log_subscriber'

module Lograge
  class Railtie < Rails::Railtie
    config.lograge = ActiveSupport::OrderedOptions.new
    config.lograge.enabled = false

    initializer :lograge do |app|
      if app.config.lograge.enabled
        app.config.action_dispatch.rack_cache[:verbose] = false
        require 'lograge/rails_ext/rack/logger'
        Lograge.remove_existing_log_subscriptions
        Lograge::RequestLogSubscriber.attach_to :action_controller
      end
    end
  end
end
