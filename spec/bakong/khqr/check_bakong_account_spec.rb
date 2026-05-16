# frozen_string_literal: true

RSpec.describe Bakong::Khqr, ".check_bakong_account" do
  let(:url) { "https://api-bakong.nbc.gov.kh/v1/check_bakong_account" }

  it "returns existed=true when the API reports responseCode 0" do
    stub_request(:post, url)
      .with(body: { accountId: "vandy@aclb" }.to_json,
            headers: { "Content-Type" => "application/json" })
      .to_return(status: 200, body: { responseCode: 0, errorCode: nil }.to_json)

    expect(described_class.check_bakong_account(url, "vandy@aclb"))
      .to eq(bakong_account_existed: true)
  end

  it "returns existed=false when the API reports errorCode 11" do
    stub_request(:post, url)
      .to_return(status: 200, body: { errorCode: 11 }.to_json)

    expect(described_class.check_bakong_account(url, "vandy@aclb"))
      .to eq(bakong_account_existed: false)
  end

  it "raises BAKONG_ACCOUNT_ID_INVALID for errorCode 12" do
    stub_request(:post, url)
      .to_return(status: 200, body: { errorCode: 12 }.to_json)

    expect { described_class.check_bakong_account(url, "vandy@aclb") }
      .to raise_error(Bakong::Khqr::Error) { |e| expect(e.code).to eq(3) }
  end

  it "raises BAKONG_ACCOUNT_ID_LENGTH_INVALID for an oversize ID before calling the network" do
    long_id = "#{'a' * 31}@x"
    expect { described_class.check_bakong_account(url, long_id) }
      .to raise_error(Bakong::Khqr::Error) { |e| expect(e.code).to eq(6) }
  end

  it "raises BAKONG_ACCOUNT_ID_INVALID for an ID missing the @ separator" do
    expect { described_class.check_bakong_account(url, "no_at_sign") }
      .to raise_error(Bakong::Khqr::Error) { |e| expect(e.code).to eq(3) }
  end

  it "raises CONNECTION_TIMEOUT when the network call fails" do
    stub_request(:post, url).to_raise(Net::OpenTimeout)
    expect { described_class.check_bakong_account(url, "vandy@aclb") }
      .to raise_error(Bakong::Khqr::Error) { |e| expect(e.code).to eq(13) }
  end
end
