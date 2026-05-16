# frozen_string_literal: true

require_relative "../constants"
require_relative "../error"
require_relative "../error_codes"
require_relative "../crc16"
require_relative "../khqr_tag" # pulls in all MerchantCode classes

module Bakong
  module Khqr
    module Controllers
      # Builds a KHQR EMVCo-TLV string from an IndividualInfo or MerchantInfo.
      module Generate
        module_function

        def call(information, type)
          merchant_info = build_merchant_info(information, type)
          additional = additional_data_input(information)
          language = language_input(information)
          amount = information.amount
          qr_type = (amount.nil? || amount.zero?) ? EMV[:STATIC_QR] : EMV[:DYNAMIC_QR]

          parts = []
          parts << MerchantCode::PayloadFormatIndicator.new(
            EMV[:PAYLOAD_FORMAT_INDICATOR], EMV[:DEFAULT_PAYLOAD_FORMAT_INDICATOR]
          )
          parts << MerchantCode::PointOfInitiationMethod.new(EMV[:POINT_OF_INITIATION_METHOD], qr_type)

          upi = nil
          if information.upi_merchant_account
            upi = MerchantCode::UnionpayMerchantAccount.new(
              EMV[:UNIONPAY_MERCHANT_ACCOUNT], information.upi_merchant_account
            )
            parts << upi
          end

          khqr_type = type == :merchant ? EMV[:MERCHANT_ACCOUNT_INFORMATION_MERCHANT] : EMV[:MERCHANT_ACCOUNT_INFORMATION_INDIVIDUAL]
          parts << MerchantCode::GlobalUniqueIdentifier.new(khqr_type, merchant_info)

          parts << MerchantCode::MerchantCategoryCode.new(
            EMV[:MERCHANT_CATEGORY_CODE],
            (information.merchant_category_code || EMV[:DEFAULT_MERCHANT_CATEGORY_CODE]).to_s
          )
          parts << MerchantCode::TransactionCurrency.new(EMV[:TRANSACTION_CURRENCY], information.currency)

          if information.currency == CURRENCY[:usd] && upi
            raise Error.from(ERROR_CODES[:UPI_ACCOUNT_INFORMATION_INVALID_CURRENCY])
          end

          unless amount.nil? || amount.zero?
            formatted = format_amount(amount, information.currency)
            parts << MerchantCode::TransactionAmount.new(EMV[:TRANSACTION_AMOUNT], formatted)
          end

          parts << MerchantCode::CountryCode.new(EMV[:COUNTRY_CODE], EMV[:DEFAULT_COUNTRY_CODE])
          parts << MerchantCode::MerchantName.new(EMV[:MERCHANT_NAME], information.merchant_name)
          parts << MerchantCode::MerchantCity.new(
            EMV[:MERCHANT_CITY],
            (information.merchant_city || EMV[:DEFAULT_MERCHANT_CITY]).to_s
          )

          unless additional.values.all? { |v| v.nil? || v == "" }
            parts << MerchantCode::AdditionalData.new(EMV[:ADDITIONAL_DATA_TAG], additional)
          end

          unless language.values.all? { |v| v.nil? || v == "" }
            parts << MerchantCode::MerchantInformationLanguageTemplate.new(
              EMV[:MERCHANT_INFORMATION_LANGUAGE_TEMPLATE], language
            )
          end

          if qr_type == EMV[:DYNAMIC_QR]
            raise Error.from(ERROR_CODES[:EXPIRATION_TIMESTAMP_REQUIRED]) unless information.expiration_timestamp

            parts << MerchantCode::TimeStamp.new(
              EMV[:TIMESTAMP_TAG],
              {
                creation_timestamp: (Time.now.to_f * 1000).to_i,
                expiration_timestamp: information.expiration_timestamp
              },
              qr_type
            )
          end

          khqr_no_crc = parts.map(&:to_s).join
          khqr_with_crc_header = "#{khqr_no_crc}#{EMV[:CRC]}#{EMV[:CRC_LENGTH]}"
          khqr_with_crc_header + CRC16.compute(khqr_with_crc_header)
        end

        def build_merchant_info(information, type)
          if type == :merchant
            {
              bakong_account_id: information.bakong_account_id,
              merchant_id: information.respond_to?(:merchant_id) ? information.merchant_id : nil,
              acquiring_bank: information.acquiring_bank,
              is_merchant: true
            }
          else
            {
              bakong_account_id: information.bakong_account_id,
              account_information: information.account_information,
              acquiring_bank: information.acquiring_bank,
              is_merchant: false
            }
          end
        end

        def additional_data_input(information)
          {
            bill_number: information.bill_number,
            mobile_number: information.mobile_number,
            store_label: information.store_label,
            terminal_label: information.terminal_label,
            purpose_of_transaction: information.purpose_of_transaction
          }
        end

        def language_input(information)
          {
            language_preference: information.language_preference,
            merchant_name_alternate_language: information.merchant_name_alternate_language,
            merchant_city_alternate_language: information.merchant_city_alternate_language
          }
        end

        # KHR requires whole numbers; USD allows up to 2 decimal places. Matches
        # the upstream JS amount normalization byte-for-byte (toFixed(2) for
        # fractional USD; integer string for whole values; raises for KHR with
        # any fractional component).
        def format_amount(value, currency)
          if currency == CURRENCY[:khr]
            raise Error.from(ERROR_CODES[:TRANSACTION_AMOUNT_INVALID]) unless (value % 1).zero?

            value.to_i.to_s
          else
            string = if value.is_a?(Float) && (value % 1).zero?
                       value.to_i.to_s
                     else
                       value.to_s
                     end

            if string.include?(".")
              precision = string.split(".", 2)[1]
              raise Error.from(ERROR_CODES[:TRANSACTION_AMOUNT_INVALID]) if precision.length > 2

              format("%.2f", value)
            else
              string
            end
          end
        end
      end
    end
  end
end
