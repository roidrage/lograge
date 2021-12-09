# frozen_string_literal: true

require 'json'
require 'action_pack'
require 'active_support/core_ext/class/attribute'
require 'active_support/log_subscriber'
require 'ddtrace'
require 'request_store'

module Lograge
  module LogSubscribers
    class Base < ActiveSupport::LogSubscriber
      def logger
        Lograge.logger.presence || super
      end

      private

      def process_main_event(event)
        return if Lograge.ignore?(event)

        payload = event.payload
        data = extract_request(event, payload)
        data = before_format(data, payload)
        formatted_message = Lograge.formatter.call(data)
        logger.send(Lograge.log_level, formatted_message)
      end

      def extract_request(event, payload)
        data = initial_data(payload)
        data.deep_merge!(datadog_trace)
        data.deep_merge!(extract_error(payload))
        data.deep_merge!(extract_status(payload))
        data.deep_merge!(extract_runtimes(event, payload))
        data.deep_merge!(extract_location)
        data.deep_merge!(extract_unpermitted_params)
        data.deep_merge!(custom_options(event))
      end

      %i[initial_data datadog_trace extract_error extract_status extract_runtimes
         extract_location extract_unpermitted_params].each do |method_name|
        define_method(method_name) { |*_arg| {} }
      end

      def datadog_trace
        # Retrieves trace information for current thread
        correlation = ::Datadog.tracer.active_correlation

        {
          # Adds IDs as tags to log output
          dd: {
            # To preserve precision during JSON serialization, use strings for large numbers
            trace_id: correlation.trace_id.to_s,
            span_id: correlation.span_id.to_s,
            env: correlation.env.to_s,
            service: correlation.service.to_s,
            version: correlation.version.to_s
          },
          ddsource: ['ruby']
        }
      end

      def extract_error(payload)
        exception_object = payload[:exception_object]
        return {} unless exception_object.present?

        # https://docs.datadoghq.com/logs/log_configuration/attributes_naming_convention/#source-code
        {
          error: {
            kind: exception_object.class.name,
            message: exception_object.message,
            stack: exception_object.backtrace&.join("\n")
          }
        }
      end

      def extract_status(payload)
        if (status = payload[:status])
          { http: { status_code: status.to_i } }
        elsif (exception = payload[:exception_object])
          { http: { status_code: get_error_status_code(exception.class.name) } }
        else
          { http: { status_code: default_status } }
        end
      end

      def default_status
        0
      end

      def get_error_status_code(exception)
        status = ActionDispatch::ExceptionWrapper.rescue_responses[exception]
        Rack::Utils.status_code(status)
      end

      def custom_options(event)
        options = Lograge.custom_options(event) || {}
        options.merge event.payload[:custom_payload] || {}
      end

      def before_format(data, payload)
        Lograge.before_format(data, payload)
      end
    end
  end
end
