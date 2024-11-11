begin
  require 'logstash-logger'
  require 'logstash-event'
rescue LoadError
  puts 'You need to install the logstash-event and logstash-logger gems ' \
    'to use Lograge::LogStashLoggerFormatters::MergedWithLogragePayload.'
  raise
end

module Lograge
  module LogStashLoggerFormatters
    class MergedWithLogragePayload < LogStashLogger::Formatter::Base
      private

      def format_event(event)
        lograge_event_payload = RequestStore.store[:lograge_event_payload] || {}
        lograge_event_payload.merge!(RequestStore.store[:lograge_custom_payload] || {})
        event.overwrite(event.fields.merge(lograge_event_payload))
        "#{event.to_json}\n"
      end
    end
  end
end
