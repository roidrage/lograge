# frozen_string_literal: true

module Lograge
  module LogSubscribers
    class ActionController < Base
      def process_action(event)
        process_main_event(event)
      end

      def redirect_to(event)
        RequestStore.store[:lograge_location] = event.payload[:location]
      end

      def unpermitted_parameters(event)
        RequestStore.store[:lograge_unpermitted_params] ||= []
        RequestStore.store[:lograge_unpermitted_params].concat(event.payload[:keys])
      end

      private

      def initial_data(payload)
        initial_data = {
          message: "#{payload[:method]} #{extract_path(payload)}",
          controller: payload[:controller],
          action: payload[:action],
          timestamp: Time.now.utc.iso8601(3)
        }

        initial_data.deep_merge!(extract_request_details(payload))
        initial_data.deep_merge!(extract_client_ip(payload))
        initial_data
      end

      def extract_request_details(payload)
        {
          http: {
            method: payload[:method],
            request_id: payload[:request].request_id,
            url: payload[:request].original_url
          }
        }
      end

      def extract_client_ip(payload)
        {
          network: {
            client: {
              ip: payload[:request].remote_ip
            }
          }
        }
      end

      def extract_path(payload)
        path = payload[:path]
        strip_query_string(path)
      end

      def strip_query_string(path)
        index = path.index('?')
        index ? path[0, index] : path
      end

      def extract_runtimes(event, payload)
        data = { duration: 1_000 * event.duration }
        data[:view] = payload[:view_runtime].to_f.round(2) if payload.key?(:view_runtime)
        data[:db] = payload[:db_runtime].to_f.round(2) if payload.key?(:db_runtime)
        data
      end

      def extract_location
        location = RequestStore.store[:lograge_location]
        return {} unless location

        RequestStore.store[:lograge_location] = nil
        { location: strip_query_string(location) }
      end

      def extract_unpermitted_params
        unpermitted_params = RequestStore.store[:lograge_unpermitted_params]
        return {} unless unpermitted_params

        RequestStore.store[:lograge_unpermitted_params] = nil
        { unpermitted_params: unpermitted_params }
      end
    end
  end
end
