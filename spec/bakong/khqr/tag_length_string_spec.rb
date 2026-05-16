# frozen_string_literal: true

RSpec.describe Bakong::Khqr::TagLengthString do
  it "zero-pads single-digit lengths" do
    tlv = described_class.new("00", "01")
    expect(tlv.length).to eq("02")
    expect(tlv.to_s).to eq("000201")
  end

  it "uses two-digit length without padding for values ≥ 10 chars" do
    tlv = described_class.new("01", "1234567890")
    expect(tlv.length).to eq("10")
    expect(tlv.to_s).to eq("01101234567890")
  end

  it "counts characters (code points), not bytes — Khmer text in BMP" do
    tlv = described_class.new("01", "ចន ស្មីន")
    expect(tlv.length).to eq("08")
    expect(tlv.to_s).to eq("0108ចន ស្មីន")
  end

  it "coerces numeric values to strings before measuring" do
    tlv = described_class.new("01", 12_345)
    expect(tlv.length).to eq("05")
    expect(tlv.to_s).to eq("010512345")
  end
end
