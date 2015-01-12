require 'lograge/version'
require 'lograge/formatters/cee'
require 'lograge/formatters/json'
require 'lograge/formatters/graylog2'
require 'lograge/formatters/key_value'
require 'lograge/formatters/l2met'
require 'lograge/formatters/lines'
require 'lograge/formatters/logstash'
require 'lograge/formatters/raw'
require 'lograge/log_subscriber'
require 'active_support/core_ext/module/attribute_accessors'
require 'active_support/core_ext/string/inflections'
require 'active_support/ordered_options'

module Lograge
  module_function

  mattr_accessor :logger, :application, :ignore_tests

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

  # Before format allows you to change the structure of the output.
  # You've to pass in something callable
  #
  mattr_writer :before_format
  self.before_format = nil

  def self.before_format(data, payload)
    result = nil
    result = @@before_format.call(data, payload) if @@before_format
    result || data
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

  def ignore_tests
    @ignore_tests ||= []
  end

  def self.ignore(test)
    ignore_tests.push(test) if test
  end

  def ignore_nothing
    @ignore_tests = []
  end

  def self.ignore?(event)
    ignore_tests.any? { |ignore_test| ignore_test.call(event) }
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
    events = subscriber.public_methods(false).reject { |method| method.to_s == 'call' }
    events.each do |event|
      ActiveSupport::Notifications.notifier.listeners_for("#{event}.#{component}").each do |listener|
        if listener.instance_variable_get('@delegate') == subscriber
          ActiveSupport::Notifications.unsubscribe listener
        end
      end
    end
  end

  def self.setup(app)
    self.application = app
    app.config.action_dispatch.rack_cache[:verbose] = false if app.config.action_dispatch.rack_cache

    unless app.config.lograge.keep_original_rails_log
      require 'lograge/rails_ext/rack/logger'
      Lograge.remove_existing_log_subscriptions
    end

    Lograge.logger = app.config.lograge.logger

    Lograge::RequestLogSubscriber.attach_to :action_controller
    Lograge.custom_options = lograge_config.custom_options
    Lograge.before_format = lograge_config.before_format
    Lograge.log_level = lograge_config.log_level || :info
    support_deprecated_config # TODO: Remove with version 1.0
    Lograge.formatter = lograge_config.formatter || Lograge::Formatters::KeyValue.new
    Lograge.ignore_actions(lograge_config.ignore_actions)
    Lograge.ignore(lograge_config.ignore_custom)
  end

  # TODO: Remove with version 1.0

  def support_deprecated_config
    return unless lograge_config.log_format

    legacy_log_format = lograge_config.log_format
    warning = 'config.lograge.log_format is deprecated. Use config.lograge.formatter instead.'
    ActiveSupport::Deprecation.warn(warning, caller)
    legacy_log_format = :key_value if legacy_log_format == :lograge
    lograge_config.formatter = "Lograge::Formatters::#{legacy_log_format.to_s.classify}".constantize.new
  end

  def lograge_config
    application.config.lograge
  end
end

require 'lograge/railtie' if defined?(Rails)
