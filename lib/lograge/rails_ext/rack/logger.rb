require 'active_support/concern'
require 'rails/rack/logger'

module Rails
  module Rack
    # Overwrites defaults of Rails::Rack::Logger that cause
    # unnecessary logging.
    # This effectively removes the log lines from the log
    # that say:
    # Started GET / for 192.168.2.1...
    class Logger
      # Overwrites Rails 3.2 code that logs new requests
      def call_app(*args)
        env = args.last
        status, headers, body = @app.call(env)
        # needs to have same return type as the Rails builtins being overridden, see https://github.com/roidrage/lograge/pull/333
        [status, headers, ::Rack::BodyProxy.new(body) {} ]
      ensure
        ActiveSupport::LogSubscriber.flush_all!
      end

      # Overwrites Rails 3.0/3.1 code that logs new requests
      def before_dispatch(_env)
      end
    end
  end
end
