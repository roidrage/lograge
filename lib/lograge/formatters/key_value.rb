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
        elsif value.is_a? Float
          value = Kernel.format('%.2f', value)
        end

        "#{key}=#{value}"
      end
    end
  end
end
