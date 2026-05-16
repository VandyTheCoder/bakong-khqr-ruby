# frozen_string_literal: true

require_relative "../tag_length_string"
require_relative "../constants"
require_relative "../error"
require_relative "../error_codes"

module Bakong
  module Khqr
    module MerchantCode
      # Tag "62". Optional sub-tags: bill_number, mobile_number, store_label,
      # terminal_label, purpose_of_transaction. Pass them in a snake_case
      # symbol hash.
      class AdditionalData < TagLengthString
        attr_reader :data, :bill_number, :mobile_number, :store_label, :terminal_label

        def initialize(tag, additional_data)
          additional_data ||= {}

          bill_number_input = additional_data[:bill_number]
          mobile_number_input = additional_data[:mobile_number]
          store_label_input = additional_data[:store_label]
          terminal_label_input = additional_data[:terminal_label]
          purpose_of_transaction = additional_data[:purpose_of_transaction]

          string = +""
          bill_number = mobile_number = store_label = terminal_label = nil

          unless bill_number_input.nil?
            bill_number = BillNumber.new(EMV[:BILLNUMBER_TAG], bill_number_input)
            string << bill_number.to_s
          end

          unless mobile_number_input.nil?
            mobile_number = MobileNumber.new(EMV[:ADDITIONAL_DATA_FIELD_MOBILE_NUMBER], mobile_number_input)
            string << mobile_number.to_s
          end

          unless store_label_input.nil?
            store_label = StoreLabel.new(EMV[:STORELABEL_TAG], store_label_input)
            string << store_label.to_s
          end

          unless terminal_label_input.nil?
            terminal_label = TerminalLabel.new(EMV[:TERMINAL_TAG], terminal_label_input)
            string << terminal_label.to_s
          end

          unless purpose_of_transaction.nil?
            purpose = PurposeOfTransaction.new(EMV[:PURPOSE_OF_TRANSACTION], purpose_of_transaction)
            string << purpose.to_s
          end

          super(tag, string)
          @bill_number = bill_number
          @mobile_number = mobile_number
          @store_label = store_label
          @terminal_label = terminal_label
          @data = {
            bill_number: bill_number,
            mobile_number: mobile_number,
            store_label: store_label,
            terminal_label: terminal_label,
            purpose_of_transaction: purpose_of_transaction
          }
        end
      end

      class BillNumber < TagLengthString
        def initialize(tag, value)
          if value.length > EMV[:INVALID_LENGTH][:BILL_NUMBER] || value == ""
            raise Error.from(ERROR_CODES[:BILL_NUMBER_LENGTH_INVALID])
          end

          super
        end
      end

      class StoreLabel < TagLengthString
        def initialize(tag, value)
          if value.length > EMV[:INVALID_LENGTH][:STORE_LABEL] || value == ""
            raise Error.from(ERROR_CODES[:STORE_LABEL_LENGTH_INVALID])
          end

          super
        end
      end

      class TerminalLabel < TagLengthString
        def initialize(tag, value)
          if value.length > EMV[:INVALID_LENGTH][:TERMINAL_LABEL] || value == ""
            raise Error.from(ERROR_CODES[:TERMINAL_LABEL_LENGTH_INVALID])
          end

          super
        end
      end

      class MobileNumber < TagLengthString
        def initialize(tag, value)
          if value.length > EMV[:INVALID_LENGTH][:MOBILE_NUMBER] || value == ""
            raise Error.from(ERROR_CODES[:MOBILE_NUMBER_LENGTH_INVALID])
          end

          super
        end
      end

      class PurposeOfTransaction < TagLengthString
        def initialize(tag, value)
          if value.length > EMV[:INVALID_LENGTH][:PURPOSE_OF_TRANSACTION] || value == ""
            raise Error.from(ERROR_CODES[:PURPOSE_OF_TRANSACTION_LENGTH_INVALID])
          end

          super
        end
      end
    end
  end
end
