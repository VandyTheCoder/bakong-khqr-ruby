# frozen_string_literal: true

RSpec.describe Bakong::Khqr, ".generate_deep_link" do
  let(:url) { "https://api-bakong.nbc.gov.kh/v1/generate_deeplink_by_qr" }
  let(:qr) do
    info = Bakong::Khqr::IndividualInfo.new(
      bakong_account_id: "john_smith@devb",
      merchant_name: "John Smith",
      merchant_city: "Phnom Penh"
    )
    Bakong::Khqr.generate_individual(info)[:qr]
  end

  it "returns the shortLink from the API response" do
    stub_request(:post, url)
      .to_return(status: 200, body: { data: { shortLink: "https://bakong.link/abc" } }.to_json)

    expect(described_class.generate_deep_link(url, qr))
      .to eq(short_link: "https://bakong.link/abc")
  end

  it "raises INVALID_DEEP_LINK_URL for a wrong path" do
    expect { described_class.generate_deep_link("https://example.com/wrong/path", qr) }
      .to raise_error(Bakong::Khqr::Error) { |e| expect(e.code).to eq(29) }
  end

  it "raises KHQR_INVALID when the QR fails CRC verification" do
    bad_qr = "00020101021230190015john_smith@devb6304DEAD"
    expect { described_class.generate_deep_link(url, bad_qr) }
      .to raise_error(Bakong::Khqr::Error) { |e| expect(e.code).to eq(8) }
  end

  it "raises INVALID_DEEP_LINK_SOURCE_INFO when source_info is incomplete" do
    incomplete = Bakong::Khqr::SourceInfo.new(app_icon_url: nil, app_name: "x", app_deep_link_callback: "x")
    expect { described_class.generate_deep_link(url, qr, source_info: incomplete) }
      .to raise_error(Bakong::Khqr::Error) { |e| expect(e.code).to eq(14) }
  end

  it "forwards a complete source_info to the API" do
    info = Bakong::Khqr::SourceInfo.new(
      app_icon_url: "https://x/icon.png", app_name: "MyApp", app_deep_link_callback: "myapp://"
    )
    stub_request(:post, url)
      .with(body: hash_including("sourceInfo" => hash_including("appName" => "MyApp")))
      .to_return(status: 200, body: { data: { shortLink: "https://bakong.link/xyz" } }.to_json)

    expect(described_class.generate_deep_link(url, qr, source_info: info))
      .to eq(short_link: "https://bakong.link/xyz")
  end
end
