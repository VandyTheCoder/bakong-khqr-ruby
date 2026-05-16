# Changelog

All notable changes to **bakong-khqr** will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.1] - 2026-05-16

### Changed
- Trimmed personal-name attribution from the gem description, README opening paragraph, and module-level comment. The upstream npm package is still credited via URL.

## [0.1.0] - 2026-05-16

### Added
- Initial Ruby port of the official [bakong-khqr](https://www.npmjs.com/package/bakong-khqr) JavaScript SDK v1.0.20.
- `Bakong::Khqr.generate_individual` and `.generate_merchant` for KHQR string + MD5 generation.
- `Bakong::Khqr.decode` and `.decode_non_khqr` for parsing KHQR (and arbitrary EMVCo TLV) payloads.
- `Bakong::Khqr.verify` for CRC-16/CCITT-FALSE checksum validation.
- `Bakong::Khqr.check_bakong_account` and `.generate_deep_link` Bakong Open API clients (`Net::HTTP`, zero gem deps).
- `Bakong::Khqr::IndividualInfo`, `MerchantInfo`, `SourceInfo`, and `CURRENCY` constants.
- RSpec parity test suite ported from the upstream npm package's Jest fixtures.
