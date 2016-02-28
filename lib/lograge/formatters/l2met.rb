require 'lograge/formatters/key_value'

module Lograge
  module Formatters
    class L2met < KeyValue
      L2MET_FIELDS = [
        :method,
        :path,
        :format,
        :source,
        :status,
        :error,
        :duration,
        :view,
        :db,
        :location
      ].freeze

      def call(data)
        super(modify_payload(data))
      end

      def format(key, value)
        key = "measure#page.#{key}" if value.is_a?(Float)

        super(key, value)
      end

      def fields_to_display(data)
        L2MET_FIELDS + (data.keys - L2MET_FIELDS) - [:controller, :action]
      end

      def modify_payload(data)
        data[:source] = source_field(data) if data[:controller] && data[:action]

        data
      end

      def source_field(data)
        "#{data[:controller].to_s.tr('/', '-')}:#{data[:action]}"
      end
    end
  end
end
