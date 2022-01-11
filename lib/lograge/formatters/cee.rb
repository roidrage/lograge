# frozen_string_literal: true

module Lograge
  module Formatters
    class Cee
      def call(data)
        "@cee: #{JSON.dump(data)}"
      end
    end
  end
end
