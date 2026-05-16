# frozen_string_literal: true

require_relative "../tag_length_string"
require_relative "../constants"
require_relative "../error"
require_relative "../error_codes"

module Bakong
  module Khqr
    module MerchantCode
      # Tag "64". Accepts a snake_case hash:
      # { language_preference:, merchant_name_alternate_language:, merchant_city_alternate_language: }
      class MerchantInformationLanguageTemplate < TagLengthString
        attr_reader :data

        def initialize(tag, value)
          value ||= {}

          if value[:language_preference] && !value[:merchant_name_alternate_language]
            raise Error.from(ERROR_CODES[:MERCHANT_NAME_ALTERNATE_LANGUAGE_REQUIRED])
          end

          string = +""

          unless value[:merchant_name_alternate_language].nil?
            preference = LanguagePreference.new(EMV[:LANGUAGE_PREFERENCE], value[:language_preference])
            string << preference.to_s

            alt_name = MerchantNameAlternateLanguage.new(
              EMV[:MERCHANT_NAME_ALTERNATE_LANGUAGE],
              value[:merchant_name_alternate_language]
            )
            string << alt_name.to_s
          end

          unless value[:merchant_city_alternate_language].nil?
            alt_city = MerchantCityAlternateLanguage.new(
              EMV[:MERCHANT_CITY_ALTERNATE_LANGUAGE],
              value[:merchant_city_alternate_language]
            )
            string << alt_city.to_s
          end

          super(tag, string)
          @data = value
        end
      end

      class LanguagePreference < TagLengthString
        def initialize(tag, value)
          if value.length > EMV[:INVALID_LENGTH][:LANGUAGE_PREFERENCE] || value == ""
            raise Error.from(ERROR_CODES[:LANGUAGE_PREFERENCE_LENGTH_INVALID])
          end

          super
        end
      end

      class MerchantNameAlternateLanguage < TagLengthString
        def initialize(tag, value)
          if value.length > EMV[:INVALID_LENGTH][:MERCHANT_NAME_ALTERNATE_LANGUAGE] || value == ""
            raise Error.from(ERROR_CODES[:MERCHANT_NAME_ALTERNATE_LANGUAGE_LENGTH_INVALID])
          end

          super
        end
      end

      class MerchantCityAlternateLanguage < TagLengthString
        def initialize(tag, value)
          if value.length > EMV[:INVALID_LENGTH][:MERCHANT_CITY_ALTERNATE_LANGUAGE] || value == ""
            raise Error.from(ERROR_CODES[:MERCHANT_CITY_ALTERNATE_LANGUAGE_LENGTH_INVALID])
          end

          super
        end
      end
    end
  end
end
