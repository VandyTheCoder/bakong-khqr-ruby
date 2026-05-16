# frozen_string_literal: true

require_relative "../tag_length_string"
require_relative "../constants"
require_relative "../error"
require_relative "../error_codes"

module Bakong
  module Khqr
    module MerchantCode
      # Tag "99". Accepts a snake_case hash:
      # { creation_timestamp:, expiration_timestamp: } where both are
      # millisecond-precision Unix timestamps (13 digits).
      class TimeStamp < TagLengthString
        def initialize(tag, timestamp, poi = nil)
          timestamp ||= {}
          creation_timestamp = (timestamp[:creation_timestamp] || 0).to_i
          expiration_timestamp = (timestamp[:expiration_timestamp] || 0).to_i

          if poi == EMV[:DYNAMIC_QR]
            if timestamp.empty? || expiration_timestamp.zero?
              raise Error.from(ERROR_CODES[:EXPIRATION_TIMESTAMP_REQUIRED])
            end

            if expiration_timestamp.to_s.length != EMV[:INVALID_LENGTH][:TIMESTAMP]
              raise Error.from(ERROR_CODES[:EXPIRATION_TIMESTAMP_LENGTH_INVALID])
            end

            begin
              Time.at(expiration_timestamp / 1000.0)
            rescue StandardError
              raise Error.from(ERROR_CODES[:INVALID_DYNAMIC_KHQR])
            end

            raise Error.from(ERROR_CODES[:EXPIRATION_TIMESTAMP_IN_THE_PAST]) if expiration_timestamp < creation_timestamp

            now_ms = (Time.now.to_f * 1000).to_i
            raise Error.from(ERROR_CODES[:KHQR_EXPIRED]) if expiration_timestamp < now_ms
          end

          string = +""
          created = TagLengthString.new(EMV[:CREATION_TIMESTAMP], creation_timestamp)
          string << created.to_s

          expired = TagLengthString.new(EMV[:EXPIRATION_TIMESTAMP], expiration_timestamp)
          string << expired.to_s

          super(tag, string)
        end
      end
    end
  end
end
