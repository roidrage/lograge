require 'rails/railtie'
require 'lograge/log_subscriber'

module Lograge
  class Railtie < Rails::Railtie
    initializer :lograge do |app|
      Lograge.remove_existing_log_subscriptions
      Lograge::LogSubscriber.attach_to 
    end
  end
end
