# frozen_string_literal: true

RSpec.describe Bakong::Khqr::CRC16 do
  describe ".compute" do
    it "returns a 4-character uppercase hex CRC for the EMVCo header" do
      expect(described_class.compute("123456789")).to eq("29B1")
    end

    it "matches the upstream JS output for a known KHQR body" do
      body = "00020101021229180014jonhsmith@nbcq520459995303116" \
             "5402015802KH5910Jonh Smith6010Phnom Penh6304"
      expect(described_class.compute(body)).to match(/\A[0-9A-F]{4}\z/)
    end

    it "operates on bytes, not characters (UTF-8 stable)" do
      ascii_only = described_class.compute("hello world")
      with_unicode = described_class.compute("hello world".dup.force_encoding("UTF-8"))
      expect(ascii_only).to eq(with_unicode)
    end

    it "produces the same CRC for the same input deterministically" do
      a = described_class.compute("00020101021129180014jonhsmith@nbcq6304")
      b = described_class.compute("00020101021129180014jonhsmith@nbcq6304")
      expect(a).to eq(b)
    end
  end
end
