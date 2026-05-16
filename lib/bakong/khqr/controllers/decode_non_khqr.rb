# frozen_string_literal: true

module Bakong
  module Khqr
    module Controllers
      # Generic EMVCo TLV decoder for QR strings that may or may not be KHQR.
      # Walks up to three levels of nested TLV for the same composite-tag
      # ranges the upstream JS package handles (26–51, 80–99, 62, 64).
      module DecodeNonKHQR
        module_function

        def call(qr)
          first_level = {}
          final_data = {}
          remainder = qr

          loop do
            parsed = extract_tlv(remainder)
            break unless valid?(parsed[:tag], parsed[:length], parsed[:value])

            first_level[parsed[:tag]] = parsed[:value]
            remainder = parsed[:remain]
            break if remainder.nil? || remainder.empty?
          end

          first_level.each do |tag, value|
            final_data[tag] = value
            next unless composite_tag?(tag)
            next if value.length < 6

            second_level = {}
            remaining_value = value

            loop do
              third_level = {}
              parsed = extract_tlv(remaining_value)
              break unless valid?(parsed[:tag], parsed[:length], parsed[:value])

              sub_tag = parsed[:tag]
              sub_value = parsed[:value]
              remaining_value = parsed[:remain]

              if tag == "62" && (50..99).cover?(sub_tag.to_i)
                inner = sub_value
                loop do
                  inner_parsed = extract_tlv(inner)
                  break unless valid?(inner_parsed[:tag], inner_parsed[:length], inner_parsed[:value])

                  third_level[inner_parsed[:tag]] = inner_parsed[:value]
                  inner = inner_parsed[:remain]
                  break if inner.nil? || inner.empty?
                end
              end

              second_level[sub_tag] = third_level.empty? ? sub_value : third_level
              break if remaining_value.nil? || remaining_value.empty?
            end

            final_data[tag] = second_level unless second_level.empty?
          end

          final_data
        end

        def extract_tlv(string)
          tag = string[0, 2].to_s
          length = string[2, 2].to_i
          value = string[4, length].to_s
          remain = string[(4 + length)..] || ""
          { tag: tag, length: length, value: value, remain: remain }
        end

        def composite_tag?(tag)
          int = tag.to_i
          (26..51).cover?(int) || (80..99).cover?(int) || tag == "64" || tag == "62"
        end

        def valid?(tag, length, value)
          tag.match?(/\A\d+\z/) && length == value.length
        end
      end
    end
  end
end
