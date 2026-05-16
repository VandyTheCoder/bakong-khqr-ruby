# frozen_string_literal: true

require_relative "http"
require_relative "../constants"
require_relative "../error"
require_relative "../error_codes"

module Bakong
  module Khqr
    module Helpers
      # Calls the Bakong Open API account-existence endpoint with a single
      # bakong account ID. Returns true/false; raises Bakong::Khqr::Error on
      # malformed input or transport failure.
      module CheckAccountID
        module_function

        def call(url, account_id)
          if account_id.length > EMV[:INVALID_LENGTH][:BAKONG_ACCOUNT]
            raise Error.from(ERROR_CODES[:BAKONG_ACCOUNT_ID_LENGTH_INVALID])
          end

          raise Error.from(ERROR_CODES[:BAKONG_ACCOUNT_ID_INVALID]) if account_id.split("@").length != 2

          response = Http.post_json(url, { accountId: account_id })
          error = response[:errorCode]
          response_code = response[:responseCode]

          return { bakong_account_existed: false } if error == 11
          raise Error.from(ERROR_CODES[:BAKONG_ACCOUNT_ID_INVALID]) if error == 12

          { bakong_account_existed: response_code.to_i.zero? }
        end
      end
    end
  end
end
