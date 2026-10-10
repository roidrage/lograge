# frozen_string_literal: true

ActiveSupport.on_load(:action_cable) do
  module ActionCable
    module Server
      class Base
        mattr_accessor :logger
        self.logger = Lograge::SilentLogger.new(config.logger)
      end
    end
  end
end
