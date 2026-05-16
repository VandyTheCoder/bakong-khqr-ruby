# frozen_string_literal: true

require_relative "../tag_length_string"
require_relative "../constants"
require_relative "../error"
require_relative "../error_codes"

module Bakong
  module Khqr
    module MerchantCode
      class TransactionAmount < TagLengthString
        def initialize(tag, value)
          string_value = value.to_s
          if string_value.length > EMV[:INVALID_LENGTH][:AMOUNT] ||
             string_value.include?("-") ||
             value.nil? ||
             string_value == ""
            raise Error.from(ERROR_CODES[:TRANSACTION_AMOUNT_INVALID])
          end

          super
        end
      end
    end
  end
end
