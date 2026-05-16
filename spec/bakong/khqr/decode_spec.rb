# frozen_string_literal: true

RSpec.describe Bakong::Khqr, ".decode" do
  let(:individual_qr) do
    info = Bakong::Khqr::IndividualInfo.new(
      bakong_account_id: "john_smith@devb",
      merchant_name: "John Smith",
      merchant_city: "Phnom Penh",
      bill_number: "Invoice#069",
      store_label: "Coffee Khlaing",
      terminal_label: "Counter 2"
    )
    Bakong::Khqr.generate_individual(info)[:qr]
  end

  it "surfaces snake_case symbol keys" do
    decoded = described_class.decode(individual_qr)
    expect(decoded[:merchant_name]).to eq("John Smith")
    expect(decoded[:merchant_city]).to eq("Phnom Penh")
    expect(decoded[:bill_number]).to eq("Invoice#069")
    expect(decoded[:store_label]).to eq("Coffee Khlaing")
    expect(decoded[:terminal_label]).to eq("Counter 2")
  end

  it "marks the merchant_type as 29 for individual QRs" do
    expect(described_class.decode(individual_qr)[:merchant_type]).to eq("29")
  end

  it "exposes the trailing CRC and country code" do
    decoded = described_class.decode(individual_qr)
    expect(decoded[:country_code]).to eq("KH")
    expect(decoded[:crc]).to match(/\A[0-9A-F]{4}\z/)
  end
end

RSpec.describe Bakong::Khqr, ".decode_non_khqr" do
  it "parses arbitrary EMVCo TLV into a string-keyed hash" do
    payload = "00020101021229180014jonhsmith@nbcq5204599953031165802KH5910Jonh Smith6010Phnom Penh6215021185512345678"
    out = described_class.decode_non_khqr(payload)
    expect(out["00"]).to eq("01")
    expect(out["29"]).to be_a(Hash)
    expect(out["29"]["00"]).to eq("jonhsmith@nbcq")
    expect(out["59"]).to eq("Jonh Smith")
    expect(out["60"]).to eq("Phnom Penh")
  end
end
