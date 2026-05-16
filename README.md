# bakong-khqr

[![Gem Version](https://badge.fury.io/rb/bakong-khqr.svg)](https://rubygems.org/gems/bakong-khqr)

A Ruby SDK for **KHQR** — the centralized QR Code used by every mobile banking
app in Cambodia. Generate, decode, and verify KHQR payloads, and talk to the
Bakong Open API.

This is a Ruby port of the official
[`bakong-khqr`](https://www.npmjs.com/package/bakong-khqr) JavaScript SDK.
The public API mirrors the npm package one-to-one; only the naming has been
Ruby-fied (snake_case methods and hash keys). Zero runtime gem dependencies —
uses only the Ruby standard library.

> **KHQR ~ Scan. Pay. Done.**

## Requirements

- Ruby `>= 3.4.1`

## Installation

Add to your Gemfile:

```ruby
gem "bakong-khqr"
```

Or install directly:

```sh
gem install bakong-khqr
```

Then require:

```ruby
require "bakong/khqr"
```

## Usage

### Generate an Individual KHQR

```ruby
require "bakong/khqr"

info = Bakong::Khqr::IndividualInfo.new(
  bakong_account_id: "vandy@aclb",
  merchant_name:     "Vandy Sodanheang",
  merchant_city:     "Phnom Penh",
  currency:          Bakong::Khqr::CURRENCY[:khr],
  amount:            50_000,
  bill_number:       "INV-2026-0001",
  mobile_number:     "85512345678",
  store_label:       "BKK-1",
  terminal_label:    "Counter-1",
  expiration_timestamp: (Time.now.to_f * 1000).to_i + 5 * 60 * 1000  # 5 min
)

result = Bakong::Khqr.generate_individual(info)
result[:qr]   # → "00020101021229180014vandy@aclb52045999..."
result[:md5]  # → MD5 digest of the QR string
```

For static QRs (no amount, no expiration), simply omit `:amount`.

### Generate a Merchant KHQR

```ruby
info = Bakong::Khqr::MerchantInfo.new(
  bakong_account_id: "vandy@aclb",
  merchant_name:     "Sodanheang Coffee",
  merchant_city:     "Phnom Penh",
  merchant_id:       "1234567890",
  acquiring_bank:    "ACLEDA Bank",
  currency:          Bakong::Khqr::CURRENCY[:usd],
  amount:            1.50,
  expiration_timestamp: (Time.now.to_f * 1000).to_i + 5 * 60 * 1000
)

Bakong::Khqr.generate_merchant(info)
# → { qr: "...", md5: "..." }
```

### Verify a KHQR

```ruby
Bakong::Khqr.verify(qr_string)  # → true | false
```

Returns `true` only when both the trailing CRC-16/CCITT-FALSE checksum and the
per-tag validation pass.

### Decode a KHQR

```ruby
decoded = Bakong::Khqr.decode(qr_string)
# → {
#     merchant_type: "29",
#     bakong_account_id: "vandy@aclb",
#     account_information: nil,
#     payload_format_indicator: "01",
#     point_of_initiation_method: "12",
#     merchant_category_code: "5999",
#     transaction_currency: "116",
#     transaction_amount: "50000",
#     country_code: "KH",
#     merchant_name: "Vandy Sodanheang",
#     merchant_city: "Phnom Penh",
#     bill_number: "INV-2026-0001",
#     mobile_number: "85512345678",
#     store_label: "BKK-1",
#     terminal_label: "Counter-1",
#     purpose_of_transaction: nil,
#     language_preference: nil,
#     merchant_name_alternate_language: nil,
#     merchant_city_alternate_language: nil,
#     creation_timestamp: "1747...",
#     expiration_timestamp: "1747...",
#     crc: "A586"
#   }
```

Use `Bakong::Khqr.decode_non_khqr(qr_string)` to decode arbitrary EMVCo TLV QRs
(returns a string-keyed hash with up to three levels of nesting).

### Check whether a Bakong account exists

```ruby
result = Bakong::Khqr.check_bakong_account(
  "https://api-bakong.nbc.gov.kh/v1/check_bakong_account",
  "vandy@aclb"
)
# → { bakong_account_existed: true }
```

### Generate a deep link

```ruby
source = Bakong::Khqr::SourceInfo.new(
  app_icon_url:           "https://yourapp.example/icon.png",
  app_name:               "Your App",
  app_deep_link_callback: "yourapp://payment-result"
)

Bakong::Khqr.generate_deep_link(
  "https://api-bakong.nbc.gov.kh/v1/generate_deeplink_by_qr",
  qr_string,
  source_info: source
)
# → { short_link: "https://bakong.link/abc123" }
```

`source_info` is optional; pass `nil` to skip it. When provided, all three
fields are required.

## Error handling

All validation and transport errors raise `Bakong::Khqr::Error`, which carries
the upstream numeric error code in `#code` and a human-readable `#message`:

```ruby
begin
  Bakong::Khqr.generate_individual(info)
rescue Bakong::Khqr::Error => e
  puts "code=#{e.code} message=#{e.message}"
end
```

Error codes (1–51) are kept identical to the upstream JavaScript SDK so that
existing dashboards and i18n strings keyed off them continue to work. See
[lib/bakong/khqr/error_codes.rb](lib/bakong/khqr/error_codes.rb) for the full
list.

## API mapping (npm → gem)

| JavaScript                                       | Ruby                                                    |
| ------------------------------------------------ | ------------------------------------------------------- |
| `BakongKHQR.prototype.generateIndividual(info)`  | `Bakong::Khqr.generate_individual(info)`                |
| `BakongKHQR.prototype.generateMerchant(info)`    | `Bakong::Khqr.generate_merchant(info)`                  |
| `BakongKHQR.decode(qr)`                          | `Bakong::Khqr.decode(qr)`                               |
| `BakongKHQR.decodeNonKhqr(qr)`                   | `Bakong::Khqr.decode_non_khqr(qr)`                      |
| `BakongKHQR.verify(qr).isValid`                  | `Bakong::Khqr.verify(qr)`                               |
| `BakongKHQR.checkBakongAccount(url, id)`         | `Bakong::Khqr.check_bakong_account(url, id)`            |
| `BakongKHQR.generateDeepLink(url, qr, source)`   | `Bakong::Khqr.generate_deep_link(url, qr, source_info:)`|
| `new IndividualInfo(id, name, city, optional)`   | `Bakong::Khqr::IndividualInfo.new(...)` (keyword args)  |
| `new MerchantInfo(id, name, city, mid, ab, opt)` | `Bakong::Khqr::MerchantInfo.new(...)` (keyword args)    |
| `new SourceInfo(icon, name, cb)`                 | `Bakong::Khqr::SourceInfo.new(...)` (keyword args)      |
| `khqrData.currency.{khr,usd}`                    | `Bakong::Khqr::CURRENCY[:khr]`, `Bakong::Khqr::CURRENCY[:usd]` |

## Development

```sh
bin/setup        # bundle install
bundle exec rspec
bundle exec rake # default task = spec
```

To open a console with the gem loaded:

```sh
bin/console
```

## Contributing

Issues and pull requests are welcome at
<https://github.com/VandyTheCoder/bakong-khqr-ruby>.

## Credits

- Upstream JavaScript SDK: [bakong-khqr](https://www.npmjs.com/package/bakong-khqr).
- KHQR specification: [National Bank of Cambodia](https://bakong.nbc.gov.kh/).

## License

MIT — see [LICENSE.txt](LICENSE.txt). All algorithm and data-structure
copyright from the upstream `bakong-khqr` npm package (ISC license) is
preserved per its terms.
