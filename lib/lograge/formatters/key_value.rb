module Lograge
  module Formatters
    class KeyValue
      LOGRAGE_FIELDS = [
        :method, :path, :format, :controller, :action, :status, :error,
        :duration, :view, :db, :location
      ]

      def call(data)
        fields  = LOGRAGE_FIELDS
        fields += (data.keys - LOGRAGE_FIELDS)

        event = fields.inject([]) do |message, key|
          next message unless data.has_key?(key)
          # Exactly preserve the previous output
          # Parsing this can be ambigious if the error messages contains
          # a single quote
          data[key] = "'#{data[key]}'" if key == :error
          # Ensure that we always have exactly two decimals
          data[key] = "%.2f" % data[key] if data[key].is_a? Float

          message << "#{key}=#{data[key]}"
          message
        end
        event.join(" ")
      end
    end
  end
end