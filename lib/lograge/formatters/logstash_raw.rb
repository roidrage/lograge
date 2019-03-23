# frozen_string_literal: true

module Lograge
  module Formatters
    # This formatter class is responsible for formatting the lograge payload as LogStash::Event.
    #
    # It can be useful when lograge logs are meant to be unified with a custom rails logger formatter,
    # where for example we want to add logger custom options.
    # In the above case can be convenient to postpone the `event.to_json` ( as it is in the child class Logstash )
    #
    # Example: Custom Rails Logger Formatter
    #
    # config/production.rb
    # ```ruby
    # Rails.application.configure do
    #   ...
    #   config.log_formatter = FooFormatter.new
    #   ...
    # end
    # ```
    #
    # my_formatter.rb
    # ```ruby
    # class FooFormatter < ActiveSupport::Logger::SimpleFormatter
    #   # This method is called everytime a log event happens
    #   def call(severity, timestamp, progname, message)
    #     return super if message.is_a? String
    #
    #     message[:one] = :custom_option
    #     message[:another] = :custom_option
    #     message[:level] = severiy
    #
    #     "#{message.to_json}\n"
    #   end
    # end
    # ```
    #
    # Now when you can:
    # ```ruby
    # Rails.logger(message: "An Amazing Log")
    # ```
    # =>
    # ```json
    # {
    #   "message": "An Amazing Log",
    #   "one": "custom_option",
    #   "another": "custom_option",
    #   "level": "INFO"
    # }
    # ```
    # The custom options will be applied to the lograge log too,
    # without the need of passing any custom option to the lograge configuration
    #
    # ```json
    # {
    #   "method": "POST",
    #   "path": "/api/v1/my_path",
    #   "controller": "Api::V1::MyPathController",
    #   "action": "create",
    #   "status": 200,
    #   "params": {
    #     "one": "param",
    #     "another": "param"
    #   },
    #   "message": "[200] POST /api/v1/my_path (Api::V1::MyPathController#create)",
    #   ...
    #   "one": "custom_option",
    #   "another": "custom_option",
    #   "level": "INFO",
    #   ...
    # }
    # ```
    class LogstashRaw
      # This method is responsible for:
      # => instantiating a LogStash::Event with the given data payload
      # => setting the message key and value
      def call(data)
        load_dependencies
        event = LogStash::Event.new(data)

        event['message'] = message(data)
        event
      end

      private

      def load_dependencies
        require 'logstash-event'
      rescue LoadError
        puts 'You need to install the logstash-event gem to use the logstash output.'
        raise
      end

      def message(data)
        "[#{data[:status]}] #{data[:method]} #{data[:path]} (#{data[:controller]}##{data[:action]})"
      end
    end
  end
end
