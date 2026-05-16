# frozen_string_literal: true

require "uri"

require_relative "http"
require_relative "../error"
require_relative "../error_codes"

module Bakong
  module Khqr
    module Helpers
      # Validates and calls the Bakong Open API deep-link generation endpoint.
      module DeepLink
        EXPECTED_PATH = "/v1/generate_deeplink_by_qr"

        module_function

        def valid_link?(link)
          uri = URI.parse(link)
          uri.path == EXPECTED_PATH
        rescue URI::InvalidURIError
          false
        end

        def call(url, payload)
          response = Http.post_json(url, payload)
          error = response[:errorCode]
          raise Error.from(ERROR_CODES[:INVALID_DEEP_LINK_SOURCE_INFO]) if error == 5
          raise Error.from(ERROR_CODES[:INTERNAL_SERVER_ERROR]) if error == 4

          response
        end
      end
    end
  end
end
