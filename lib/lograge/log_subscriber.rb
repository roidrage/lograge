require 'json'

require 'active_support/core_ext/class/attribute'
require 'active_support/log_subscriber'

module Lograge
  class RequestLogSubscriber < ActiveSupport::LogSubscriber
    def process_action(event)
      return if Lograge.ignore?(event)
      
      payload = event.payload

      data      = extract_request(payload)
      data.merge! extract_status(payload)
      data.merge! runtimes(event)
      data.merge! location(event)
      data.merge! custom_options(event)

      formatted_message = Lograge.formatter.call(data)
      logger.send(Lograge.log_level, formatted_message)
    end

    def redirect_to(event)
      Thread.current[:lograge_location] = event.payload[:location]
    end

    def logger
      Lograge.logger.presence or super
    end

    private

    def extract_request(payload)
      {
        :method => payload[:method],
        :path => extract_path(payload),
        :format => extract_format(payload),
        :controller => payload[:params]['controller'],
        :action => payload[:params]['action']
      }
    end

    def extract_path(payload)
      payload[:path].split("?").first
    end

    def extract_format(payload)
      if ::ActionPack::VERSION::MAJOR == 3 && ::ActionPack::VERSION::MINOR == 0
        payload[:formats].first
      else
        payload[:format]
      end
    end

    def extract_status(payload)
      if payload[:status]
        { :status => payload[:status].to_i }
      elsif payload[:exception]
        exception, message = payload[:exception]
        { :status => 500, :error => "#{exception}:#{message}" }
      else
        { :status => 0 }
      end
    end

    def custom_options(event)
      Lograge.custom_options(event) || {}
    end

    def runtimes(event)
      {
        :duration => event.duration,
        :view => event.payload[:view_runtime],
        :db => event.payload[:db_runtime]
      }.inject({}) do |runtimes, (name, runtime)|
        runtimes[name] = runtime.to_f.round(2) if runtime
        runtimes
      end
    end

    def location(event)
      if location = Thread.current[:lograge_location]
        Thread.current[:lograge_location] = nil
        { :location => location }
      else
        {}
      end
    end
  end
end
