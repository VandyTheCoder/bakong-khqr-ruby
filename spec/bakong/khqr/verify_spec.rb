# frozen_string_literal: true

RSpec.describe Bakong::Khqr, ".verify" do
  it "returns true for a QR it just generated" do
    info = Bakong::Khqr::IndividualInfo.new(
      bakong_account_id: "john_smith@devb",
      merchant_name: "John Smith",
      merchant_city: "Phnom Penh"
    )
    qr = described_class.generate_individual(info)[:qr]
    expect(described_class.verify(qr)).to be(true)
  end

  it "returns false when the CRC has been tampered with" do
    info = Bakong::Khqr::IndividualInfo.new(
      bakong_account_id: "john_smith@devb",
      merchant_name: "John Smith",
      merchant_city: "Phnom Penh"
    )
    qr = described_class.generate_individual(info)[:qr]
    tampered = "#{qr[0...-4]}DEAD"
    expect(described_class.verify(tampered)).to be(false)
  end

  it "returns false for strings that don't end with the 6304XXXX CRC tag" do
    expect(described_class.verify("ABC")).to be(false)
    expect(described_class.verify("")).to be(false)
    expect(described_class.verify("00020101")).to be(false)
  end

  it "returns false for non-string input" do
    expect(described_class.verify(nil)).to be(false)
    expect(described_class.verify(12_345)).to be(false)
  end

  it "is lowercase-CRC tolerant (case-insensitive trailing tag)" do
    info = Bakong::Khqr::IndividualInfo.new(
      bakong_account_id: "john_smith@devb",
      merchant_name: "John Smith",
      merchant_city: "Phnom Penh"
    )
    qr = described_class.generate_individual(info)[:qr]
    lowercased = "#{qr[0...-4]}#{qr[-4..].downcase}"
    expect(described_class.verify(lowercased)).to be(true)
  end
end
