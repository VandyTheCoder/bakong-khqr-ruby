# frozen_string_literal: true

require_relative "merchant_code/payload_format_indicator"
require_relative "merchant_code/point_of_initiation_method"
require_relative "merchant_code/unionpay_merchant_account"
require_relative "merchant_code/global_unique_identifier"
require_relative "merchant_code/merchant_category_code"
require_relative "merchant_code/transaction_currency"
require_relative "merchant_code/transaction_amount"
require_relative "merchant_code/country_code"
require_relative "merchant_code/merchant_name"
require_relative "merchant_code/merchant_city"
require_relative "merchant_code/additional_data"
require_relative "merchant_code/merchant_information_language_template"
require_relative "merchant_code/time_stamp"
require_relative "merchant_code/crc"

module Bakong
  module Khqr
    # Authoritative ordered list of top-level EMVCo tags the KHQR spec accepts,
    # paired with the TLV builder/validator class responsible for that tag.
    KHQR_TAG = [
      { tag: "00", type: :payload_format_indicator,                required: true,  instance: MerchantCode::PayloadFormatIndicator },
      { tag: "01", type: :point_of_initiation_method,              required: false, instance: MerchantCode::PointOfInitiationMethod },
      { tag: "15", type: :union_pay_merchant,                      required: false, instance: MerchantCode::UnionpayMerchantAccount },
      { tag: "29", type: :global_unique_identifier,                required: true,  sub: true, instance: MerchantCode::GlobalUniqueIdentifier },
      { tag: "52", type: :merchant_category_code,                  required: true,  instance: MerchantCode::MerchantCategoryCode },
      { tag: "53", type: :transaction_currency,                    required: true,  instance: MerchantCode::TransactionCurrency },
      { tag: "54", type: :transaction_amount,                      required: false, instance: MerchantCode::TransactionAmount },
      { tag: "58", type: :country_code,                            required: true,  instance: MerchantCode::CountryCode },
      { tag: "59", type: :merchant_name,                           required: true,  instance: MerchantCode::MerchantName },
      { tag: "60", type: :merchant_city,                           required: true,  instance: MerchantCode::MerchantCity },
      { tag: "62", type: :additional_data,                         required: false, sub: true, instance: MerchantCode::AdditionalData },
      { tag: "64", type: :merchant_information_language_template,  required: false, sub: true, instance: MerchantCode::MerchantInformationLanguageTemplate },
      { tag: "99", type: :timestamp,                               required: false, sub: true, instance: MerchantCode::TimeStamp },
      { tag: "63", type: :crc,                                     required: true,  instance: MerchantCode::CRC }
    ].freeze
  end
end
