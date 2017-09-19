module Lograge
  module Formatters
    class Logstash
      def call(data, type = 'controller')
        load_dependencies
        data.delete(:headers) unless data[:headers].is_a?(Hash) # NOTE:for rails 5.1 support
        event = LogStash::Event.new(data)

        event['message'] = "[#{data[:status]}] #{data[:method]} #{data[:path]} (#{data[:controller]}##{data[:action]})" if type == 'controller'
        event['message'] = data[:message] if type == 'job'
        event.to_json
      end

      def load_dependencies
        require 'logstash-event'
      rescue LoadError
        puts 'You need to install the logstash-event gem to use the logstash output.'
        raise
      end
    end
  end
end
