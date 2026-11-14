# frozen_string_literal: true

require 'json'

module Lograge
  module Formatters
    module Helpers
      # Serializes log data to JSON without dropping the whole log event when
      # the data cannot be generated as-is. Newer versions of the json gem are
      # stricter about their input:
      #
      # * json 3.1 rejects non-ASCII ASCII-8BIT (binary) strings, which are
      #   common in exception messages and HTTP response bodies.
      # * json 3.0 rejects hashes with keys that serialize to the same name,
      #   such as +:status+ and <tt>"status"</tt>.
      #
      # Strings that are invalid UTF-8 have always been rejected.
      #
      # The data is only normalized after the first attempt fails, so well
      # formed events are serialized exactly as before and pay no extra cost.
      module SafeJson
        GENERATION_ERRORS = [::JSON::GeneratorError, ::EncodingError].freeze

        module_function

        def dump(data)
          ::JSON.dump(data)
        rescue *GENERATION_ERRORS
          ::JSON.dump(normalize(data))
        end

        # Returns a copy of +value+ that the json gem can always generate:
        #
        # * every hash key is a UTF-8 string. When two keys serialize to the same
        #   name, the first key keeps its position and the later value wins,
        #   which matches how the log subscriber merges custom options.
        # * every string and symbol becomes a valid UTF-8 string. Bytes that
        #   cannot be converted are replaced with U+FFFD.
        # * other objects are kept if they can be generated on their own, and
        #   are otherwise replaced by their normalized +to_s+ (for example an
        #   exception whose message holds binary bytes).
        def normalize(value)
          case value
          when Hash then normalize_hash(value)
          when Array then value.map { |element| normalize(element) }
          when String then to_utf8(value)
          when Symbol then to_utf8(value.to_s)
          when Numeric, true, false, nil then value
          else normalize_object(value)
          end
        end

        def normalize_hash(hash)
          hash.each_with_object({}) do |(key, value), normalized|
            normalized[to_utf8(key.to_s)] = normalize(value)
          end
        end

        def normalize_object(object)
          ::JSON.dump(object)
          object
        rescue *GENERATION_ERRORS
          to_utf8(object.to_s)
        end

        def to_utf8(string)
          encoding = string.encoding
          if encoding == Encoding::UTF_8
            string.valid_encoding? ? string : string.scrub
          elsif encoding == Encoding::BINARY || encoding.dummy?
            # Binary strings carry no encoding information, and dummy encodings
            # (such as UTF-7) have no converter. Treat them as UTF-8 on a
            # best-effort basis so valid multibyte sequences survive.
            string.dup.force_encoding(Encoding::UTF_8).scrub
          else
            string.encode(Encoding::UTF_8, invalid: :replace, undef: :replace)
          end
        end
      end
    end
  end
end
