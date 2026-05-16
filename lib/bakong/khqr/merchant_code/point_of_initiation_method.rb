# frozen_string_literal: true

require_relative "../tag_length_string"
require_relative "../constants"
require_relative "../error"
require_relative "../error_codes"

module Bakong
  module Khqr
    module MerchantCode
      class PointOfInitiationMethod < TagLengthString
        def initialize(tag, value)
          raise Error.from(ERROR_CODES[:POINT_INITIATION_LENGTH_INVALID]) if value.to_s.length > 2
          unless [EMV[:STATIC_QR], EMV[:DYNAMIC_QR]].include?(value)
            raise Error.from(ERROR_CODES[:POINT_OF_INITIATION_METHOD_INVALID])
          end

          super
        end
      end
    end
  end
end
