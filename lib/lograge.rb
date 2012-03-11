require 'lograge/version'
require 'active_support/core_ext/module/attribute_accessors'
require 'active_support/core_ext/string/inflections'

module Lograge
  mattr_accessor :logger  

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
end

require 'lograge/railtie' if defined?(Rails)
