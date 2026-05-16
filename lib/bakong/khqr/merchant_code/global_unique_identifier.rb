# frozen_string_literal: true

require_relative "../tag_length_string"
require_relative "../constants"
require_relative "../error"
require_relative "../error_codes"

module Bakong
  module Khqr
    module MerchantCode
      # Tag "29" (individual) or "30" (merchant). Wraps a bakong account ID
      # plus optional merchant/account-information subtags.
      class GlobalUniqueIdentifier < TagLengthString
        attr_reader :data, :bakong_account_id, :merchant_id, :acquiring_bank, :account_information

        # value_object is expected to have snake_case keys:
        # :bakong_account_id, :merchant_id, :acquiring_bank, :account_information, :is_merchant
        def initialize(tag, value_object)
          raise Error.from(ERROR_CODES[:MERCHANT_TYPE_REQUIRED]) if value_object.nil?

          bakong_account_id_value = value_object[:bakong_account_id]
          merchant_id_value = value_object[:merchant_id]
          acquiring_bank_value = value_object[:acquiring_bank]
          account_information_value = value_object[:account_information]
          is_merchant = value_object[:is_merchant]

          bakong_account_id = BakongAccountID.new(EMV[:BAKONG_ACCOUNT_IDENTIFIER], bakong_account_id_value)
          identifier_string = +bakong_account_id.to_s

          if is_merchant
            merchant_id = MerchantId.new(EMV[:MERCHANT_ACCOUNT_INFORMATION_MERCHANT_ID], merchant_id_value)
            acquiring_bank_obj = AcquiringBank.new(EMV[:MERCHANT_ACCOUNT_INFORMATION_ACQUIRING_BANK], acquiring_bank_value)
            identifier_string << merchant_id.to_s unless merchant_id_value.nil?
            identifier_string << acquiring_bank_obj.to_s unless acquiring_bank_value.nil?

            super(tag, identifier_string)
            @merchant_id = merchant_id
            @acquiring_bank = acquiring_bank_obj
            @data = {
              bakong_account_id: bakong_account_id,
              merchant_id: merchant_id,
              acquiring_bank: acquiring_bank_obj
            }
          else
            unless account_information_value.nil?
              account_info = AccountInformation.new(EMV[:INDIVIDUAL_ACCOUNT_INFORMATION], account_information_value)
              identifier_string << account_info.to_s
            end

            unless acquiring_bank_value.nil?
              acquiring_bank_obj = AcquiringBank.new(EMV[:MERCHANT_ACCOUNT_INFORMATION_ACQUIRING_BANK], acquiring_bank_value)
              identifier_string << acquiring_bank_obj.to_s
            end

            super(tag, identifier_string)
            @account_information = account_information_value
            @data = {
              bakong_account_id: bakong_account_id,
              account_information: account_information_value
            }
          end

          @bakong_account_id = bakong_account_id
        end
      end

      class BakongAccountID < TagLengthString
        def initialize(tag, bakong_account_id)
          raise Error.from(ERROR_CODES[:BAKONG_ACCOUNT_ID_REQUIRED]) if bakong_account_id.nil? || bakong_account_id == ""

          parts = bakong_account_id.split("@")
          if bakong_account_id.length > EMV[:INVALID_LENGTH][:BAKONG_ACCOUNT]
            raise Error.from(ERROR_CODES[:BAKONG_ACCOUNT_ID_LENGTH_INVALID])
          end
          raise Error.from(ERROR_CODES[:BAKONG_ACCOUNT_ID_INVALID]) if parts.length < 2

          super
        end
      end

      class AccountInformation < TagLengthString
        def initialize(tag, value)
          if value.length > EMV[:INVALID_LENGTH][:ACCOUNT_INFORMATION]
            raise Error.from(ERROR_CODES[:ACCOUNT_INFORMATION_LENGTH_INVALID])
          end

          super
        end
      end

      class MerchantId < TagLengthString
        def initialize(tag, value)
          raise Error.from(ERROR_CODES[:MERCHANT_ID_REQUIRED]) if value.nil? || value == ""
          raise Error.from(ERROR_CODES[:MERCHANT_ID_LENGTH_INVALID]) if value.length > EMV[:INVALID_LENGTH][:MERCHANT_ID]

          super
        end
      end

      class AcquiringBank < TagLengthString
        def initialize(tag, value)
          raise Error.from(ERROR_CODES[:ACQUIRING_BANK_REQUIRED]) if value.nil? || value == ""
          if value.length > EMV[:INVALID_LENGTH][:ACQUIRING_BANK]
            raise Error.from(ERROR_CODES[:ACQUIRING_BANK_LENGTH_INVALID])
          end

          super
        end
      end
    end
  end
end
