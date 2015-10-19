module Lograge
  module CustomEvent
    class << self
      def log(hash)
        logger.public_send(Lograge.log_level, Lograge.formatter.call(hash))
      end

      private

      def logger
        Lograge.logger || defined?(Rails) && Rails.logger || fail('No logger available')
      end
    end
  end
end
