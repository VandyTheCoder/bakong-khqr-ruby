# frozen_string_literal: true

module Bakong
  module Khqr
    class Error < StandardError
      attr_reader :code

      def initialize(code:, message:)
        @code = code
        super(message)
      end

      def self.from(error_code)
        new(code: error_code[:code], message: error_code[:message])
      end
    end
  end
end
