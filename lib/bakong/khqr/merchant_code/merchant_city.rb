# frozen_string_literal: true

require_relative "../tag_length_string"
require_relative "../constants"
require_relative "../error"
require_relative "../error_codes"

module Bakong
  module Khqr
    module MerchantCode
      class MerchantCity < TagLengthString
        def initialize(tag, value)
          raise Error.from(ERROR_CODES[:MERCHANT_CITY_TAG_REQUIRED]) if value.nil? || value == ""
          raise Error.from(ERROR_CODES[:MERCHANT_CITY_LENGTH_INVALID]) if value.length > EMV[:INVALID_LENGTH][:MERCHANT_CITY]

          super
        end
      end
    end
  end
end
