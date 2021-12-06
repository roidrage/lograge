# frozen_string_literal: true

module Lograge
  module LogSubscribers
    class ActionCable < Base
      %i[perform_action subscribe unsubscribe connect disconnect].each do |method_name|
        define_method(method_name) do |event|
          process_main_event(event)
        end
      end

      private

      def initial_data(payload)
        {
          format: {},
          params: payload[:data],
          controller: payload[:channel_class] || payload[:connection_class],
          action: payload[:action],
          timestamp: Time.now.utc.iso8601(3)
        }
      end

      def default_status
        200
      end

      def extract_runtimes(event, _payload)
        { duration: 1_000 * event.duration }
      end
    end
  end
end
