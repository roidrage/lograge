require 'json'

require 'active_support/core_ext/class/attribute'
require 'active_support/log_subscriber'

module Lograge
  class RequestLogSubscriber < ActiveSupport::LogSubscriber
    def process_action(event)
      return if Lograge.ignore?(event)

      payload = event.payload

      data      = extract_request(payload)
      extract_status(data, payload)
      runtimes(data, event)
      location(data, event)
      custom_options(data, event)

      data = before_format(data, payload)
      formatted_message = Lograge.formatter.call(data)
      logger.send(Lograge.log_level, formatted_message)
    end

    def redirect_to(event)
      Thread.current[:lograge_location] = event.payload[:location]
    end

    def logger
      Lograge.logger.presence || super
    end

    private

    def extract_request(payload)
      {
        method: payload[:method],
        path: extract_path(payload),
        format: extract_format(payload),
        controller: payload[:params]['controller'],
        action: payload[:params]['action']
      }
    end

    def extract_path(payload)
      payload[:path].split('?').first
    end

    if ::ActionPack::VERSION::MAJOR == 3 && ::ActionPack::VERSION::MINOR == 0
      def extract_format(payload)
        payload[:formats].first
      end
    else
      def extract_format(payload)
        payload[:format]
      end
    end

    def extract_status(data, payload)
      if (status = payload[:status])
        data[:status] = status.to_i
      elsif (error = payload[:exception])
        exception, message = error
        data[:status] = 500
        data[:error]  = "#{exception}:#{message}"
      else
        data[:status] = 0
      end
    end

    def custom_options(data, event)
      options = Lograge.custom_options(event)
      data.merge! options if options
    end

    def before_format(data, payload)
      Lograge.before_format(data, payload)
    end

    def runtimes(data, event)
      payload = event.payload
      data[:duration] = event.duration.to_f.round(2)
      data[:view]     = payload[:view_runtime].to_f.round(2) if payload.key?(:view_runtime)
      data[:db]       = payload[:db_runtime].to_f.round(2) if payload.key?(:db_runtime)
    end

    def location(data, _event)
      location = Thread.current[:lograge_location]
      return unless location

      Thread.current[:lograge_location] = nil
      data[:location] = location
    end
  end
end
