# frozen_string_literal: true

module Bakong
  module Khqr
    # EMVCo TLV primitive: a 2-char tag, 2-digit zero-padded length, and value.
    # Length is the character count of the value (matches the JS upstream's
    # `String.length`, which counts UTF-16 code units — equivalent to Ruby's
    # `String#length` for any character in the BMP, which covers Khmer).
    class TagLengthString
      attr_reader :tag, :length, :value

      def initialize(tag, value)
        @tag = tag
        @value = value
        len = value.to_s.length
        @length = len < 10 ? "0#{len}" : len.to_s
      end

      def to_s
        "#{@tag}#{@length}#{@value}"
      end
    end
  end
end
