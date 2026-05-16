# frozen_string_literal: true

RSpec.describe Bakong::Khqr, ".generate_merchant" do
  let(:base) do
    {
      bakong_account_id: "jonhsmith@nbcq",
      merchant_name: "Jonh Smith",
      merchant_city: "Phnom Penh",
      merchant_id: "1234567890",
      acquiring_bank: "Dev Bank"
    }
  end

  it "produces a tag-30 KHQR with merchant + acquiring bank subtags" do
    info = Bakong::Khqr::MerchantInfo.new(**base)
    result = described_class.generate_merchant(info)
    expect(result[:qr]).to start_with("00020101021130")
    expect(result[:qr]).to include("0014jonhsmith@nbcq")
    expect(result[:qr]).to include("0110123456789002") # merchant_id 01<len>value
    expect(result[:qr]).to include("0208Dev Bank")
  end

  it "round-trips through decode with merchant_type=30" do
    info = Bakong::Khqr::MerchantInfo.new(**base)
    qr = described_class.generate_merchant(info)[:qr]
    decoded = described_class.decode(qr)
    expect(decoded[:merchant_type]).to eq("30")
    expect(decoded[:bakong_account_id]).to eq("jonhsmith@nbcq")
    expect(decoded[:merchant_id]).to eq("1234567890")
    expect(decoded[:acquiring_bank]).to eq("Dev Bank")
  end

  it "verifies its own CRC after generation" do
    info = Bakong::Khqr::MerchantInfo.new(**base)
    qr = described_class.generate_merchant(info)[:qr]
    expect(described_class.verify(qr)).to be(true)
  end

  it "raises MERCHANT_ID_REQUIRED when merchant_id is blank at construction" do
    expect do
      Bakong::Khqr::MerchantInfo.new(**base, merchant_id: nil)
    end.to raise_error(ArgumentError)
  end
end
