module Lograge
  module Formatters
    class KeyValue
      def call(data)
        fields = fields_to_display(data)

        event = fields.reduce([]) do |message, key|
          message << format(key, data[key])
          message
        end
        event.join(' ')
      end

      def fields_to_display(data)
        data.keys
      end

      def format(key, value)
        # Exactly preserve the previous output
        # Parsing this can be ambigious if the error messages contains
        # a single quote
        value = "'#{value}'" if key == :error

        # Ensure that we always have exactly two decimals
        value = Kernel.format('%.2f', value) if value.is_a? Float

        "#{key}=#{value}"
      end
    end
  end
end
