# frozen_string_literal: true

require_relative "../tag_length_string"
require_relative "../constants"
require_relative "../error"
require_relative "../error_codes"

module Bakong
  module Khqr
    module MerchantCode
      class TransactionCurrency < TagLengthString
        def initialize(tag, value)
          raise Error.from(ERROR_CODES[:CURRENCY_TYPE_REQUIRED]) if value.nil? || value == ""

          string_value = value.to_s
          raise Error.from(ERROR_CODES[:TRANSACTION_CURRENCY_LENGTH_INVALID]) if string_value.length > 3

          unless [CURRENCY[:khr], CURRENCY[:usd]].include?(string_value.to_i)
            raise Error.from(ERROR_CODES[:UNSUPPORTED_CURRENCY])
          end

          super(tag, string_value)
        end
      end
    end
  end
end
