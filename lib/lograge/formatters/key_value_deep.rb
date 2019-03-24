module Lograge
  module Formatters
    class KeyValueDeep < KeyValue
      def call(data)
        super flatten_keys(data)
      end

      protected

      def flatten_keys(data, prefix='')
        case data
        when Array
          result = {}
          data.each_with_index do |value, key|
            key = "#{prefix}_#{key}" if prefix.length > 0
            if [Hash, Array].include? value.class
              result.merge!(flatten_keys(value, key))
            else
              result[key] = value
            end
          end
          return result
        when Hash
          result = {}
          data.map do |key, value|
            key = "#{prefix}_#{key}" if prefix.length > 0
            if [Hash, Array].include? value.class
              result.merge!(flatten_keys(value, key))
            else
              result[key] = value
            end
          end
          return result
        end
        data
      end
    end
  end
end
