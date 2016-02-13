module Lograge
  module Formatters
    class LTSV
      def call(data)
        fields = fields_to_display(data)

        event = fields.map { |key| format(key, data[key]) }
        event.join("\t")
      end

      def fields_to_display(data)
        data.keys
      end

      def format(key, value)
        if key == :error
          # Exactly preserve the previous output
          # Parsing this can be ambigious if the error messages contains
          # a single quote
          value = "'#{escape value}'"
        else
          # Ensure that we always have exactly two decimals
          value = Kernel.format('%.2f', value) if value.is_a? Float
        end

        "#{key}:#{value}"
      end

      private

      def escape(string)
        value = string.is_a?(String) ? string.dup : string.to_s

        value.gsub!('\\', '\\\\')
        value.gsub!('\n', '\\n')
        value.gsub!('\r', '\\r')
        value.gsub!('\t', '\\t')

        value
      end
    end
  end
end
