require 'rails/railtie'

module Lograge
  class Railtie < Rails::Railtie
    config.lograge = ActiveSupport::OrderedOptions.new
    config.lograge.enabled = false

    initializer :lograge do |app|
      Lograge.setup(app) if app.config.lograge.enabled

    end
  end
end
