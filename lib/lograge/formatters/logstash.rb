module Lograge
  module Formatters
    class Logstash < LogstashRaw
      def call(data)
        super.to_json
      end
    end
  end
end
