# frozen_string_literal: true

require_relative "constants"

module Bakong
  module Khqr
    # Subtag schema for the composite top-level tags (29, 30, 62, 64, 99).
    # `input` defines the keys we surface in a decoded result; `compare` is the
    # lookup table mapping (tag, sub_tag) → field name.
    KHQR_SUBTAG = {
      input: [
        { tag: "29", data: { bakong_account_id: nil, account_information: nil } },
        { tag: "30", data: { bakong_account_id: nil, merchant_id: nil, acquiring_bank: nil } },
        { tag: "62", data: {
          bill_number: nil, mobile_number: nil, store_label: nil,
          terminal_label: nil, purpose_of_transaction: nil
        } },
        { tag: "64", data: {
          language_preference: nil,
          merchant_name_alternate_language: nil,
          merchant_city_alternate_language: nil
        } },
        { tag: "99", data: { creation_timestamp: nil, expiration_timestamp: nil } }
      ].freeze,

      compare: [
        { tag: "29", sub_tag: EMV[:BAKONG_ACCOUNT_IDENTIFIER],                       name: :bakong_account_id },
        { tag: "29", sub_tag: EMV[:MERCHANT_ACCOUNT_INFORMATION_MERCHANT_ID],        name: :account_information },
        { tag: "29", sub_tag: EMV[:MERCHANT_ACCOUNT_INFORMATION_ACQUIRING_BANK],     name: :acquiring_bank },
        { tag: "62", sub_tag: EMV[:BILLNUMBER_TAG],                                  name: :bill_number },
        { tag: "62", sub_tag: EMV[:ADDITIONAL_DATA_FIELD_MOBILE_NUMBER],             name: :mobile_number },
        { tag: "62", sub_tag: EMV[:STORELABEL_TAG],                                  name: :store_label },
        { tag: "62", sub_tag: EMV[:PURPOSE_OF_TRANSACTION],                          name: :purpose_of_transaction },
        { tag: "62", sub_tag: EMV[:TERMINAL_TAG],                                    name: :terminal_label },
        { tag: "64", sub_tag: EMV[:LANGUAGE_PREFERENCE],                             name: :language_preference },
        { tag: "64", sub_tag: EMV[:MERCHANT_NAME_ALTERNATE_LANGUAGE],                name: :merchant_name_alternate_language },
        { tag: "64", sub_tag: EMV[:MERCHANT_CITY_ALTERNATE_LANGUAGE],                name: :merchant_city_alternate_language },
        { tag: "99", sub_tag: EMV[:CREATION_TIMESTAMP],                              name: :creation_timestamp },
        { tag: "99", sub_tag: EMV[:EXPIRATION_TIMESTAMP],                            name: :expiration_timestamp }
      ].freeze
    }.freeze
  end
end
