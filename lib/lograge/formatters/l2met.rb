require 'lograge/formatters/key_value'

module Lograge
  module Formatters
    class L2met < KeyValue
      def format(key, value)
        key = "measure#page.#{key}" if value.kind_of?(Float)

        super(key, value)
      end
    end
  end
end
