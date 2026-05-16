# frozen_string_literal: true

require_relative "lib/bakong/khqr/version"

Gem::Specification.new do |spec|
  spec.name          = "bakong-khqr"
  spec.version       = Bakong::Khqr::VERSION
  spec.authors       = ["Vandy Sodanheang"]
  spec.email         = ["vandysodanheang@gmail.com"]

  spec.summary       = "Ruby SDK for KHQR (Khmer QR Code) — generate, decode, and verify Bakong KHQR strings."
  spec.description   = <<~DESC
    A Ruby port of the official bakong-khqr JavaScript SDK
    (https://www.npmjs.com/package/bakong-khqr) by Devit Huotkeo.

    Generate Individual and Merchant KHQR payloads, decode existing KHQR strings,
    verify the embedded CRC-16/CCITT-FALSE checksum, and call the Bakong Open API
    to check accounts and produce deep links. Zero runtime gem dependencies — uses
    only the Ruby standard library.
  DESC
  spec.homepage      = "https://github.com/VandyTheCoder/bakong-khqr-ruby"
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 3.4.1"

  spec.metadata["homepage_uri"]    = spec.homepage
  spec.metadata["changelog_uri"]   = "#{spec.homepage}/blob/main/CHANGELOG.md"
  spec.metadata["bug_tracker_uri"] = "#{spec.homepage}/issues"

  spec.files = Dir.chdir(__dir__) do
    Dir["lib/**/*.rb", "*.md", "LICENSE.txt", "bakong-khqr.gemspec"]
  end
  spec.require_paths = ["lib"]
  spec.bindir        = "exe"
  spec.executables   = []
end
