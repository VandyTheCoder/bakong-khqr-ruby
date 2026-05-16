# frozen_string_literal: true

require_relative "../tag_length_string"
require_relative "../constants"
require_relative "../error"
require_relative "../error_codes"

module Bakong
  module Khqr
    module MerchantCode
      class MerchantCategoryCode < TagLengthString
        def initialize(tag, value)
          raise Error.from(ERROR_CODES[:MERCHANT_CATEGORY_TAG_REQUIRED]) if value.nil? || value == ""

          if value.length > EMV[:INVALID_LENGTH][:MERCHANT_CATEGORY_CODE]
            raise Error.from(ERROR_CODES[:MERCHANT_CODE_LENGTH_INVALID])
          end

          raise Error.from(ERROR_CODES[:INVALID_MERCHANT_CATEGORY_CODE]) unless value.match?(/\A\d+\z/)

          mcc = value.to_i
          raise Error.from(ERROR_CODES[:INVALID_MERCHANT_CATEGORY_CODE]) if mcc.negative? || mcc > 9999

          super
        end
      end
    end
  end
end
