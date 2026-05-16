# frozen_string_literal: true

require_relative "constants"

module Bakong
  module Khqr
    # Payload describing an individual KHQR recipient. Mirrors the upstream
    # JS `IndividualInfo` class but uses Ruby keyword arguments instead of a
    # positional + options-hash signature.
    class IndividualInfo
      ATTRS = %i[
        bakong_account_id merchant_name merchant_city account_information acquiring_bank
        currency amount bill_number store_label terminal_label mobile_number
        purpose_of_transaction language_preference merchant_name_alternate_language
        merchant_city_alternate_language upi_merchant_account expiration_timestamp
        merchant_category_code
      ].freeze

      attr_accessor(*ATTRS)

      def initialize(bakong_account_id:, merchant_name:, merchant_city:, **optional)
        validate_string!(:bakong_account_id, bakong_account_id)
        validate_string!(:merchant_name, merchant_name)
        validate_string!(:merchant_city, merchant_city)

        @bakong_account_id = bakong_account_id
        @merchant_name = merchant_name
        @merchant_city = merchant_city

        cleaned = optional.reject { |_, v| v.nil? || v == "" }

        @account_information = cleaned[:account_information]
        @acquiring_bank = cleaned[:acquiring_bank]
        @currency = cleaned.fetch(:currency, CURRENCY[:khr])
        @amount = cleaned[:amount]
        @bill_number = cleaned[:bill_number]
        @store_label = cleaned[:store_label]
        @terminal_label = cleaned[:terminal_label]
        @mobile_number = cleaned[:mobile_number]
        @purpose_of_transaction = cleaned[:purpose_of_transaction]
        @language_preference = cleaned[:language_preference]
        @merchant_name_alternate_language = cleaned[:merchant_name_alternate_language]
        @merchant_city_alternate_language = cleaned[:merchant_city_alternate_language]
        @upi_merchant_account = cleaned[:upi_merchant_account]
        @expiration_timestamp = cleaned[:expiration_timestamp]
        @merchant_category_code = cleaned[:merchant_category_code]
      end

      private

      def validate_string!(name, value)
        return if value.is_a?(String)

        raise ArgumentError, "#{name} must be a string"
      end
    end
  end
end
