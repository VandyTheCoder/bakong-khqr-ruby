# frozen_string_literal: true

module Bakong
  module Khqr
    module Helpers
      # Slice off a single TLV (tag, length, value) from the head of an EMVCo
      # string. Returns the parsed parts plus whatever remains for the caller
      # to keep consuming.
      module CutString
        module_function

        def call(string)
          tag = string[0, 2]
          length = string[2, 2].to_i
          value = string[4, length]
          remainder = string[(4 + length)..] || ""
          { tag: tag, value: value || "", remainder: remainder }
        end
      end
    end
  end
end
