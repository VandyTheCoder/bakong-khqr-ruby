# frozen_string_literal: true

require_relative "../constants"
require_relative "../khqr_tag"
require_relative "../khqr_subtag"
require_relative "../helpers/cut_string"

module Bakong
  module Khqr
    module Controllers
      # Parses a KHQR string into a snake_case symbol-keyed Hash. Tag 30
      # (merchant) is normalized to tag 29 in the output so downstream
      # consumers only need to handle one merchant_type discriminator.
      module Decode
        module_function

        def call(khqr_string)
          all_fields = KHQR_TAG.map { |el| el[:tag] }
          subtag_set = KHQR_TAG.select { |el| el[:sub] }.map { |el| el[:tag] }
          sub_tag_input = KHQR_SUBTAG[:input]
          sub_tag_compare = KHQR_SUBTAG[:compare]

          tags = {}
          merchant_type = nil
          last_tag = ""
          is_merchant_tag = false
          remainder = khqr_string

          until remainder.nil? || remainder.empty?
            slice = Helpers::CutString.call(remainder)
            tag = slice[:tag]
            value = slice[:value]
            remainder = slice[:remainder]

            break if tag == last_tag

            if tag == "30"
              merchant_type = "30"
              tag = "29"
              is_merchant_tag = true
            elsif tag == "29"
              merchant_type = "29"
            end

            tags[tag] = value if all_fields.include?(tag)
            last_tag = tag
          end

          decode_value = { merchant_type: merchant_type }
          sub_tag_input.each { |el| decode_value.merge!(el[:data]) }

          KHQR_TAG.each do |khqr_tag|
            tag = khqr_tag[:tag]
            value = tags[tag]
            input_value = value

            if subtag_set.include?(tag)
              schema = sub_tag_input.find { |el| el[:tag] == tag }[:data]
              input_data = deep_dup(schema)

              while value && !value.empty?
                cut = Helpers::CutString.call(value)
                sub_tag = cut[:tag]
                sub_value = cut[:value]
                value = cut[:remainder]

                name_subtag = sub_tag_compare
                              .select { |el| el[:tag] == tag }
                              .find { |el| el[:sub_tag] == sub_tag }

                next unless name_subtag

                name = name_subtag[:name]
                name = :merchant_id if is_merchant_tag && name == :account_information
                input_data[name] = sub_value
                input_value = input_data
              end

              decode_value.merge!(input_value) if input_value.is_a?(Hash)
            else
              decode_value[khqr_tag[:type]] = value
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
