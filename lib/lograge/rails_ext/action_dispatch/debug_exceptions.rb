require 'action_dispatch/middleware/debug_exceptions'

module Lograge
  module DebugExceptions
    def log_error(request, wrapper)
      payload = {
        path: request.fullpath,
        method: request.method,
        format: request.format.ref,
        exception: [wrapper.exception.class.name, wrapper.exception.message]
      }
      ActiveSupport::Notifications.instrument 'process_exception.action_controller', payload
      super(request, wrapper) if lograge_config.keep_original_rails_log
    end
  end
  ActionDispatch::DebugExceptions.prepend DebugExceptions
end
