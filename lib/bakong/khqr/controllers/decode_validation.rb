# frozen_string_literal: true

require_relative "../constants"
require_relative "../error"
require_relative "../error_codes"
require_relative "../khqr_tag"
require_relative "../khqr_subtag"
require_relative "../helpers/cut_string"

module Bakong
  module Khqr
    module Controllers
      # Walks a candidate KHQR string TLV-by-TLV, instantiating each tag's
      # validator class. Used by `verify` after the CRC check passes.
      module DecodeValidation
        module_function

        def call(khqr_string)
          all_fields = KHQR_TAG.map { |el| el[:tag] }
          subtag_set = KHQR_TAG.select { |el| el[:sub] }.map { |el| el[:tag] }
          required_fields = KHQR_TAG.select { |el| el[:required] }.map { |el| el[:tag] }
          sub_tag_input = KHQR_SUBTAG[:input]
          sub_tag_compare = KHQR_SUBTAG[:compare]

          tags = []
          merchant_type = "individual"
          last_tag = ""
          remainder = khqr_string

          until remainder.nil? || remainder.empty?
            slice = Helpers::CutString.call(remainder)
            tag = slice[:tag]
            value = slice[:value]
            remainder = slice[:remainder]

            break if tag == last_tag

            if tag == "30"
              merchant_type = "merchant"
              tag = "29"
            end

            if all_fields.include?(tag)
              tags << { tag: tag, value: value }
              required_fields.delete(tag)
            end

            last_tag = tag
          end

          if tags.any? { |t| t[:tag] == "01" && t[:value] == "12" }
            raise Error.from(ERROR_CODES[:INVALID_DYNAMIC_KHQR]) unless tags.any? { |t| t[:tag] == "54" }
            raise Error.from(ERROR_CODES[:EXPIRATION_TIMESTAMP_REQUIRED]) unless tags.any? { |t| t[:tag] == "99" }
          end

          if tags.any? { |t| t[:tag] == "54" } && tags.none? { |t| t[:tag] == "99" }
            raise Error.from(ERROR_CODES[:EXPIRATION_TIMESTAMP_REQUIRED])
          end

          unless required_fields.empty?
            required_tag = required_fields.first
            missing_instance = KHQR_TAG.find { |el| el[:tag] == required_tag }[:instance]
            missing_instance.new(required_tag, nil) # raises with the proper error
          end

          decode_value = { merchant_type: merchant_type }
          sub_tag_input.each { |el| decode_value.merge!(el[:data]) }

          poi = nil
          tags.each do |khqr_tag|
            tag = khqr_tag[:tag]
            schema = KHQR_TAG.find { |el| el[:tag] == tag }
            value = khqr_tag[:value]
            input_value = value
            poi = value if tag == EMV[:POINT_OF_INITIATION_METHOD]

            if subtag_set.include?(tag)
              input_data_template = sub_tag_input.find { |el| el[:tag] == tag }[:data]
              input_data = deep_dup(input_data_template)

              while value && !value.empty?
                cut = Helpers::CutString.call(value)
                sub_tag = cut[:tag]
                sub_value = cut[:value]
                value = cut[:remainder]

                name_subtag = sub_tag_compare
                              .select { |el| el[:tag] == tag }
                              .find { |el| el[:sub_tag] == sub_tag }

                next unless name_subtag

                input_data[name_subtag[:name]] = sub_value
                input_value = input_data
              end

              decode_value.merge!(input_value) if input_value.is_a?(Hash)

              if tag == EMV[:TIMESTAMP_TAG]
                schema[:instance].new(tag, input_value, poi)
              else
                schema[:instance].new(tag, input_value)
              end
            else
              instance = schema[:instance].new(tag, input_value)
              decode_value[schema[:type]] = instance.value
            end
          end

          decode_value
        end

        def deep_dup(hash)
          hash.each_with_object({}) { |(k, v), acc| acc[k] = v.is_a?(Hash) ? deep_dup(v) : v }
        end
      end
    end
  end
end
