require 'lograge/version'
require 'lograge/log_subscriber'
require 'active_support/core_ext/module/attribute_accessors'
require 'active_support/core_ext/string/inflections'
require 'active_support/ordered_options'

module Lograge
  mattr_accessor :logger

  # Custom options that will be appended to log line
  #
  # Currently supported formats are:
  #  - Hash
  #  - Any object that responds to call and returns a hash
  #
  mattr_writer :custom_options
  self.custom_options = nil

  def self.custom_options(event)
    if @@custom_options.respond_to?(:call)
      @@custom_options.call(event)
    else
      @@custom_options
    end
  end

  # The emitted log format
  #
  # Currently supported formats are>
  #  - :lograge - The custom tense lograge format
  #  - :logstash - JSON formatted as a Logstash Event.
  mattr_accessor :log_format
  self.log_format = :lograge

  def self.remove_existing_log_subscriptions
    ActiveSupport::LogSubscriber.log_subscribers.each do |subscriber|
      case subscriber
      when ActionView::LogSubscriber
        unsubscribe(:action_view, subscriber)
      when ActionController::LogSubscriber
        unsubscribe(:action_controller, subscriber)
      end
    end
  end

  def self.unsubscribe(component, subscriber)
    events = subscriber.public_methods(false).reject{ |method| method.to_s == 'call' }
    events.each do |event|
      ActiveSupport::Notifications.notifier.listeners_for("#{event}.#{component}").each do |listener|
        if listener.instance_variable_get('@delegate') == subscriber
          ActiveSupport::Notifications.unsubscribe listener
        end
      end
    end
  end

  def self.setup(app)
    app.config.action_dispatch.rack_cache[:verbose] = false if app.config.action_dispatch.rack_cache
    require 'lograge/rails_ext/rack/logger'
    Lograge.remove_existing_log_subscriptions
    Lograge::RequestLogSubscriber.attach_to :action_controller
    Lograge.custom_options = app.config.lograge.custom_options
    Lograge.log_format = app.config.lograge.log_format || :lograge
    case Lograge.log_format.to_s
    when "logstash"
      begin
        require "logstash-event"
      rescue LoadError
        puts "You need to install the logstash-event gem to use the logstash output."
        raise
      end
    end
  end
end

require 'lograge/railtie' if defined?(Rails)
