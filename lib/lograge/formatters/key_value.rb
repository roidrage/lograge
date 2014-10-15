module Lograge
  module Formatters
    class KeyValue
      def call(data)
        fields = fields_to_display(data)

        event = fields.map { |key| format(key, data[key]) }
        event.join(' ')
      end

      def fields_to_display(data)
        data.keys
      end

      def format(key, value)
        if key == :error
          # Exactly preserve the previous output
          # Parsing this can be ambigious if the error messages contains
          # a single quote
          value = "'#{value}'"
        else
          # Ensure that we always have exactly two decimals
          value = Kernel.format('%.2f', value) if value.is_a? Float
        end

        "#{key}=#{value}"
      end
    end
  end
end
