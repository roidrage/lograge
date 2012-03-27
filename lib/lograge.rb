require 'lograge/version'
require 'lograge/log_subscriber'
require 'active_support/core_ext/module/attribute_accessors'
require 'active_support/core_ext/string/inflections'
require 'active_support/ordered_options'

module Lograge
  mattr_accessor :logger

  mattr_accessor :extra

  def self.extra_info(event)
    extra.call(event) if self.extra
  end

  def self.remove_existing_log_subscriptions
    %w(redirect_to process_action start_processing send_data write_fragment exist_fragment? send_file).each do |event|
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
    Lograge.extra = app.config.lograge.extra
  end
end

require 'lograge/railtie' if defined?(Rails)
