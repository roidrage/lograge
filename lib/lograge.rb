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

  def self.remove_existing_log_subscriptions
    %w(redirect_to process_action halted_callback start_processing send_data send_file write_fragment read_fragment exist_fragment? expire_fragment expire_page write_page).each do |event|
      unsubscribe_from_event(:action_controller, event)
    end

    %w{render_template render_partial render_collection}.each do |event|
      unsubscribe_from_event(:action_view, event)
    end
  end

  def self.unsubscribe_from_event(component, event)
    delegate_type = component.to_s.classify
    ActiveSupport::Notifications.notifier.listeners_for("#{event}.#{component}").each do |listener|
      if listener.inspect =~ /delegate[^a-z]+#{delegate_type}/
        ActiveSupport::Notifications.unsubscribe listener
      end
    end
  end

  def self.setup(app)
    app.config.action_dispatch.rack_cache[:verbose] = false if app.config.action_dispatch.rack_cache
    require 'lograge/rails_ext/rack/logger'
    Lograge.remove_existing_log_subscriptions
    Lograge::RequestLogSubscriber.attach_to :action_controller
    Lograge.custom_options = app.config.lograge.custom_options
  end
end

require 'lograge/railtie' if defined?(Rails)
