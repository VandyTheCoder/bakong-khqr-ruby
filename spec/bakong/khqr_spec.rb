# frozen_string_literal: true

RSpec.describe Bakong::Khqr do
  it "exposes a semver version constant" do
    expect(Bakong::Khqr::VERSION).to match(/\A\d+\.\d+\.\d+(\.\w+)?\z/)
  end

  it "exposes the supported currency map" do
    expect(Bakong::Khqr::CURRENCY).to eq(usd: 840, khr: 116)
  end

  it "exposes the merchant_type enum" do
    expect(Bakong::Khqr::MERCHANT_TYPE).to eq(merchant: "merchant", individual: "individual")
  end

  it "defines the EMV tag constants" do
    expect(Bakong::Khqr::EMV[:CRC]).to eq("63")
    expect(Bakong::Khqr::EMV[:DYNAMIC_QR]).to eq("12")
    expect(Bakong::Khqr::EMV[:STATIC_QR]).to eq("11")
  end

  it "wraps error codes in an exception with a `code` reader" do
    err = Bakong::Khqr::Error.from(Bakong::Khqr::ERROR_CODES[:KHQR_INVALID])
    expect(err).to be_a(StandardError)
    expect(err.code).to eq(8)
    expect(err.message).to eq("KHQR provided is invalid")
  end
end
