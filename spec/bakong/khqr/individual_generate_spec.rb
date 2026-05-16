# frozen_string_literal: true

RSpec.describe Bakong::Khqr, ".generate_individual" do
  # Test fixtures ported one-for-one from the upstream npm package
  # (test/individualGenerate.test.js). Each expected payload is compared
  # against the generated QR with the dynamic-only suffix sliced off:
  #   - amount present  → slice off 46 trailing chars (timestamp + CRC tail)
  #   - amount absent   → slice off 8 trailing chars (just the CRC tail)
  expiration_timestamp = (Time.now.to_f * 1000).to_i + (60 * 1000)

  shared_examples "matches upstream fixture" do |required:, optional:, expected:|
    it "produces the expected KHQR prefix" do
      info = Bakong::Khqr::IndividualInfo.new(**required, **optional)
      result = described_class.generate_individual(info)
      slice_count = optional.key?(:amount) ? 46 : 8
      expect(result[:qr][0...-slice_count]).to eq(expected)
    end
  end

  include_examples "matches upstream fixture",
                   required: { bakong_account_id: "jonhsmith@nbcq", merchant_name: "Jonh Smith", merchant_city: "PHNOM PENH" },
                   optional: { currency: Bakong::Khqr::CURRENCY[:usd], amount: 1, bill_number: "INV-2021-07-65822", expiration_timestamp: expiration_timestamp },
                   expected: "00020101021229180014jonhsmith@nbcq520459995303840540115802KH5910Jonh Smith6010PHNOM PENH62210117INV-2021-07-65822"

  include_examples "matches upstream fixture",
                   required: { bakong_account_id: "jonhsmith@nbcq", merchant_name: "Jonh Smith", merchant_city: "Phnom Penh" },
                   optional: { currency: Bakong::Khqr::CURRENCY[:khr], amount: 50_000, mobile_number: "85512345678", expiration_timestamp: expiration_timestamp },
                   expected: "00020101021229180014jonhsmith@nbcq5204599953031165405500005802KH5910Jonh Smith6010Phnom Penh6215021185512345678"

  include_examples "matches upstream fixture",
                   required: { bakong_account_id: "jonhsmith@nbcq", merchant_name: "Jonh Smith", merchant_city: "Phnom Penh" },
                   optional: { amount: 50_000, store_label: "BKK-1", expiration_timestamp: expiration_timestamp },
                   expected: "00020101021229180014jonhsmith@nbcq5204599953031165405500005802KH5910Jonh Smith6010Phnom Penh62090305BKK-1"

  include_examples "matches upstream fixture",
                   required: { bakong_account_id: "jonhsmith@nbcq", merchant_name: "Jonh Smith", merchant_city: "Siam Reap" },
                   optional: {
                     currency: Bakong::Khqr::CURRENCY[:khr], amount: 50_000, mobile_number: "85512345678",
                     bill_number: "INV-2021-07-65822", store_label: "BKK-1", terminal_label: "012345",
                     expiration_timestamp: expiration_timestamp
                   },
                   expected: "00020101021229180014jonhsmith@nbcq5204599953031165405500005802KH5910Jonh Smith6009Siam Reap62550117INV-2021-07-658220211855123456780305BKK-10706012345"

  include_examples "matches upstream fixture",
                   required: { bakong_account_id: "jonhsmith@nbcq", merchant_name: "Jonh Smith", merchant_city: "Siam Reap" },
                   optional: {
                     currency: Bakong::Khqr::CURRENCY[:khr], amount: 50_000, acquiring_bank: "Dev Bank",
                     account_information: "012345678", mobile_number: "85512345678",
                     bill_number: "INV-2021-07-65822", store_label: "BKK-1", terminal_label: "012345",
                     expiration_timestamp: expiration_timestamp
                   },
                   expected: "00020101021229430014jonhsmith@nbcq01090123456780208Dev Bank5204599953031165405500005802KH5910Jonh Smith6009Siam Reap62550117INV-2021-07-658220211855123456780305BKK-10706012345"

  include_examples "matches upstream fixture",
                   required: { bakong_account_id: "jonhsmith@nbcq", merchant_name: "Jonh Smith", merchant_city: "Siam Reap" },
                   optional: {
                     language_preference: "km",
                     merchant_name_alternate_language: "ចន ស្មីន",
                     merchant_city_alternate_language: "សៀមរាប"
                   },
                   expected: "00020101021129180014jonhsmith@nbcq5204599953031165802KH5910Jonh Smith6009Siam Reap64280002km0108ចន ស្មីន0206សៀមរាប"

  include_examples "matches upstream fixture",
                   required: { bakong_account_id: "jonhsmith@nbcq", merchant_name: "Jonh Smith", merchant_city: "Phnom Penh" },
                   optional: { mobile_number: "85512345678", purpose_of_transaction: "Testing" },
                   expected: "00020101021129180014jonhsmith@nbcq5204599953031165802KH5910Jonh Smith6010Phnom Penh62260211855123456780807Testing"

  describe "amount formatting" do
    let(:base_required) { { bakong_account_id: "jonhsmith@nbcq", merchant_name: "Jonh Smith", merchant_city: "Siam Reap" } }
    let(:base_optional) do
      {
        acquiring_bank: "Dev Bank", mobile_number: "85512345678",
        bill_number: "INV-2021-07-65822", store_label: "BKK-1",
        terminal_label: "012345", account_information: "012345678",
        expiration_timestamp: expiration_timestamp
      }
    end

    [
      { currency: :khr, amount: 100.0,         expected: "100" },
      { currency: :khr, amount: 10_000,        expected: "10000" },
      { currency: :khr, amount: 9_999_999_999, expected: "9999999999" },
      { currency: :usd, amount: 1.12,          expected: "1.12" },
      { currency: :usd, amount: 1000,          expected: "1000" },
      { currency: :usd, amount: 100.11,        expected: "100.11" },
      { currency: :usd, amount: 100.12,        expected: "100.12" },
      { currency: :usd, amount: 12_345_678_901.0, expected: "12345678901" },
      { currency: :usd, amount: 9_999_999_999.99, expected: "9999999999.99" }
    ].each do |row|
      it "encodes #{row[:currency].upcase} #{row[:amount].inspect} → #{row[:expected].inspect}" do
        info = Bakong::Khqr::IndividualInfo.new(
          **base_required, currency: Bakong::Khqr::CURRENCY[row[:currency]], amount: row[:amount], **base_optional
        )
        result = described_class.generate_individual(info)
        decoded = described_class.decode(result[:qr])
        expect(decoded[:transaction_amount]).to eq(row[:expected])
      end
    end

    it "raises TRANSACTION_AMOUNT_INVALID for KHR with a fractional amount" do
      info = Bakong::Khqr::IndividualInfo.new(
        **base_required, currency: Bakong::Khqr::CURRENCY[:khr], amount: 100.5, **base_optional
      )
      expect { described_class.generate_individual(info) }
        .to raise_error(Bakong::Khqr::Error) { |e| expect(e.code).to eq(4) }
    end

    it "raises TRANSACTION_AMOUNT_INVALID for USD with more than 2 decimal places" do
      info = Bakong::Khqr::IndividualInfo.new(
        **base_required, currency: Bakong::Khqr::CURRENCY[:usd], amount: 1.234, **base_optional
      )
      expect { described_class.generate_individual(info) }
        .to raise_error(Bakong::Khqr::Error) { |e| expect(e.code).to eq(4) }
    end
  end

  describe "validation errors" do
    it "raises BAKONG_ACCOUNT_ID_INVALID for an account without @" do
      info = Bakong::Khqr::IndividualInfo.new(
        bakong_account_id: "no_at_sign", merchant_name: "X", merchant_city: "Y"
      )
      expect { described_class.generate_individual(info) }
        .to raise_error(Bakong::Khqr::Error) { |e| expect(e.code).to eq(3) }
    end

    it "raises EXPIRATION_TIMESTAMP_REQUIRED for dynamic QR (amount present) without expiry" do
      info = Bakong::Khqr::IndividualInfo.new(
        bakong_account_id: "ok@bank", merchant_name: "X", merchant_city: "Y", amount: 100
      )
      expect { described_class.generate_individual(info) }
        .to raise_error(Bakong::Khqr::Error) { |e| expect(e.code).to eq(45) }
    end
  end
end
