# frozen_string_literal: true

require_relative "../tag_length_string"
require_relative "../error"
require_relative "../error_codes"

module Bakong
  module Khqr
    module MerchantCode
      class CRC < TagLengthString
        def initialize(tag, value)
          raise Error.from(ERROR_CODES[:CRC_TAG_REQUIRED]) if value.nil? || value == ""
          raise Error.from(ERROR_CODES[:CRC_LENGTH_INVALID]) if value.length > 4

          super
        end
      end
    end
  end
end
