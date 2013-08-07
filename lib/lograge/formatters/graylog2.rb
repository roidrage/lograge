module Lograge
  module Formatters
    class Graylog2
      def call(data)
        # Cloning because we don't want to mess with the original when mutating keys.
        my = data.clone

        base = {
          :short_message => "[#{my[:status]}] #{my[:method]} #{my[:path]} (#{my[:controller]}##{my[:action]})"
        }

        # Add underscore to every key to follow GELF additional field syntax.
        my.keys.each { |k| my["_#{k}".to_sym] = my[k]; my.delete(k) }

        my.merge(base)
      end
    end
  end
end