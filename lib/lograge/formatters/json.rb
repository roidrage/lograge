# frozen_string_literal: true

require 'json'
module Lograge
  module Formatters
    class Json
      def call(data)
        Helpers::SafeJson.dump(data)
      end
    end
  end
end
