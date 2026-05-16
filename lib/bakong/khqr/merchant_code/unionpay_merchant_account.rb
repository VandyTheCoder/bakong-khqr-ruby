# frozen_string_literal: true

require_relative "../tag_length_string"
require_relative "../constants"
require_relative "../error"
require_relative "../error_codes"

module Bakong
  module Khqr
    module MerchantCode
      class UnionpayMerchantAccount < TagLengthString
        def initialize(tag, value)
          if value.to_s.length > EMV[:INVALID_LENGTH][:UPI_MERCHANT]
            raise Error.from(ERROR_CODES[:UPI_ACCOUNT_INFORMATION_LENGTH_INVALID])
          end

          super
        end
      end
    end
  end
end
