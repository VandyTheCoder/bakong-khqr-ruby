# frozen_string_literal: true

require_relative "individual_info"

module Bakong
  module Khqr
    # MerchantInfo extends IndividualInfo with the merchant ID and acquiring
    # bank fields required by the merchant KHQR path (tag 30).
    class MerchantInfo < IndividualInfo
      attr_accessor :merchant_id

      def initialize(bakong_account_id:, merchant_name:, merchant_city:,
                     merchant_id:, acquiring_bank:, **optional)
        super(
          bakong_account_id: bakong_account_id,
          merchant_name: merchant_name,
          merchant_city: merchant_city,
          **optional
        )

        unless merchant_id.is_a?(String) && acquiring_bank.is_a?(String)
          raise ArgumentError, "merchant_id and acquiring_bank must be strings"
        end

        @merchant_id = merchant_id
        @acquiring_bank = acquiring_bank
      end
    end
  end
end
