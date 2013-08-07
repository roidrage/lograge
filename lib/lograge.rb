require 'lograge/version'
require 'lograge/formatters/cee'
require 'lograge/formatters/graylog2'
require 'lograge/formatters/key_value'
require 'lograge/formatters/logstash'
require 'lograge/formatters/raw'
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

  # Set conditions for events that should be ignored
  #
  # Currently supported formats are:
  #  - A single string representing a controller action, e.g. 'users#sign_in'
  #  - An array of strings representing controller actions
  #  - An object that responds to call with an event argument and returns
  #    true iff the event should be ignored.
  #
  # The action ignores are given to 'ignore_actions'. The callable ignores 
  # are given to 'ignore'.  Both methods can be called multiple times, which
  # just adds more ignore conditions to a list that is checked before logging.

  def self.ignore_actions(actions)
    ignore(lambda do |event|
      params = event.payload[:params]
      Array(actions).include?("#{params['controller']}##{params['action']}")
    end)
  end

  def self.ignore_tests
    @@ignore_tests ||= []
  end

  def self.ignore(test)
    ignore_tests.push(test) if test
  end

  def self.ignore_nothing
    @@ignore_tests = []
  end

  def self.ignore?(event)
    ignore_tests.any?{|ignore_test| ignore_test.call(event)}
  end

  # Loglines are emitted with this log level
  mattr_accessor :log_level
  self.log_level = :info

  # The emitted log format
  #
  # Currently supported formats are>
  #  - :lograge - The custom tense lograge format
  #  - :logstash - JSON formatted as a Logstash Event.
  mattr_accessor :formatter

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
    Lograge.log_level = app.config.lograge.log_level || :info
    self.support_deprecated_config(app) # TODO: Remove with version 1.0
    Lograge.formatter = app.config.lograge.formatter || Lograge::Formatters::KeyValue.new
    Lograge.ignore_actions(app.config.lograge.ignore_actions)
    Lograge.ignore(app.config.lograge.ignore_custom)
  end

  # TODO: Remove with version 1.0
  def self.support_deprecated_config(app)
    if legacy_log_format = app.config.lograge.log_format
      ActiveSupport::Deprecation.warn 'config.lograge.log_format is deprecated. Use config.lograge.formatter instead.', caller
      legacy_log_format = :key_value if legacy_log_format == :lograge
      app.config.lograge.formatter = "Lograge::Formatters::#{legacy_log_format.to_s.classify}".constantize.new
    end
  end
end

require 'lograge/railtie' if defined?(Rails)
