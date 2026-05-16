# frozen_string_literal: true

require "digest"

require_relative "khqr/version"
require_relative "khqr/constants"
require_relative "khqr/error"
require_relative "khqr/error_codes"
require_relative "khqr/tag_length_string"
require_relative "khqr/crc16"
require_relative "khqr/source_info"
require_relative "khqr/individual_info"
require_relative "khqr/merchant_info"
require_relative "khqr/helpers/cut_string"
require_relative "khqr/helpers/http"
require_relative "khqr/helpers/deep_link"
require_relative "khqr/helpers/check_account_id"
require_relative "khqr/khqr_tag"
require_relative "khqr/khqr_subtag"
require_relative "khqr/controllers/generate"
require_relative "khqr/controllers/decode"
require_relative "khqr/controllers/decode_non_khqr"
require_relative "khqr/controllers/decode_validation"

module Bakong
  # Top-level facade for the bakong-khqr SDK. Mirrors the public surface of the
  # upstream JavaScript package (https://www.npmjs.com/package/bakong-khqr):
  # generate, decode, verify, plus the Bakong Open API helpers.
  module Khqr
    CRC_REGEXP = /6304[A-Fa-f0-9]{4}\z/

    module_function

    # Generate a KHQR string for an individual recipient.
    # @param info [Bakong::Khqr::IndividualInfo]
    # @return [Hash] { qr: String, md5: String }
    def generate_individual(info)
      qr = Controllers::Generate.call(info, :individual)
      { qr: qr, md5: Digest::MD5.hexdigest(qr) }
    end

    # Generate a KHQR string for a merchant.
    # @param info [Bakong::Khqr::MerchantInfo]
    # @return [Hash] { qr: String, md5: String }
    def generate_merchant(info)
      qr = Controllers::Generate.call(info, :merchant)
      { qr: qr, md5: Digest::MD5.hexdigest(qr) }
    end

    # Parse a KHQR string into a snake_case symbol-keyed Hash.
    # @param khqr_string [String]
    # @return [Hash]
    def decode(khqr_string)
      Controllers::Decode.call(khqr_string)
    end

    # Parse an arbitrary EMVCo TLV QR string (not necessarily KHQR-compliant).
    # @param qr [String]
    # @return [Hash]
    def decode_non_khqr(qr)
      Controllers::DecodeNonKHQR.call(qr)
    end

    # Verify the CRC-16/CCITT-FALSE checksum embedded at the tail of a KHQR
    # string and re-validate every TLV against the spec.
    # @param khqr_string [String]
    # @return [Boolean]
    def verify(khqr_string)
      return false unless khqr_string.is_a?(String)
      return false unless khqr_string.match?(CRC_REGEXP)

      crc = khqr_string[-4..]
      body = khqr_string[0...-4]
      return false unless CRC16.compute(body) == crc.upcase
      return false if khqr_string.length < EMV[:INVALID_LENGTH][:KHQR]

      Controllers::DecodeValidation.call(khqr_string)
      true
    rescue Error, StandardError
      false
    end

    # Check whether a Bakong account ID exists via the Bakong Open API.
    # @param url [String]
    # @param account_id [String] e.g. "vandy@aclb"
    # @return [Hash] { bakong_account_existed: Boolean }
    # @raise [Bakong::Khqr::Error] on transport failure or invalid input.
    def check_bakong_account(url, account_id)
      Helpers::CheckAccountID.call(url, account_id)
    end

    # Request a shortened deep link for a KHQR string via the Bakong Open API.
    # @param url [String] the full deep-link endpoint URL
    # @param qr [String]
    # @param source_info [Bakong::Khqr::SourceInfo, nil] optional
    # @return [Hash] { short_link: String }
    # @raise [Bakong::Khqr::Error]
    def generate_deep_link(url, qr, source_info: nil)
      raise Error.from(ERROR_CODES[:INVALID_DEEP_LINK_URL]) unless Helpers::DeepLink.valid_link?(url)
      raise Error.from(ERROR_CODES[:KHQR_INVALID]) unless verify(qr)

      if source_info && !source_info.complete?
        raise Error.from(ERROR_CODES[:INVALID_DEEP_LINK_SOURCE_INFO])
      end

      payload = { qr: qr }
      payload[:sourceInfo] = source_info.to_h if source_info

      response = Helpers::DeepLink.call(url, payload)
      short_link = response.dig(:data, :shortLink)
      { short_link: short_link }
    end
  end
end
