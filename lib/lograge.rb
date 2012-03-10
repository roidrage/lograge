require "lograge/version"
require 'active_support/core_ext/module/attribute_accessors'

module Lograge
  mattr_accessor :logger  

  def self.remove_existing_log_subscriptions
    %w(redirect_to process_action start_processing send_data write_fragment exist_fragment? send_file).each do |event|
      ActiveSupport::Notifications.notifier.listeners_for("#{event}.action_controller").each do |listener|
        if listener.inspect =~ /delegate[^a-z]+ActionController/
          ActiveSupport::Notifications.unsubscribe listener
        end
      end

    end

    %w{render_template render_partial render_collection}.each do |event|
      ActiveSupport::Notifications.notifier.listeners_for("#{event}.action_view").each do |listener|
        if listener.inspect =~ /delegate[^a-z]+ActionView/
          ActiveSupport::Notifications.unsubscribe listener
        end
      end
    end
  end
end

require 'lograge/railtie' if defined? Rails::Railtie
