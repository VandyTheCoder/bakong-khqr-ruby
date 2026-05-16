# frozen_string_literal: true

require "net/http"
require "uri"
require "json"

require_relative "../error"
require_relative "../error_codes"

module Bakong
  module Khqr
    module Helpers
      # Net::HTTP wrapper for the Bakong Open API. Pure stdlib — no Faraday,
      # HTTParty, or gem dependency. Errors normalize into Bakong::Khqr::Error
      # so callers can catch a single exception type.
      module Http
        DEFAULT_TIMEOUT_SECONDS = 45

        module_function

        def post_json(url, payload, timeout: DEFAULT_TIMEOUT_SECONDS)
          uri = URI.parse(url)
          http = Net::HTTP.new(uri.host, uri.port)
          http.use_ssl = (uri.scheme == "https")
          http.open_timeout = timeout
          http.read_timeout = timeout

          request = Net::HTTP::Post.new(uri.request_uri)
          request["Content-Type"] = "application/json"
          request.body = JSON.generate(payload)

          response = http.request(request)
          parse_json(response.body)
        rescue Net::OpenTimeout, Net::ReadTimeout, SocketError, Errno::ECONNREFUSED, Errno::EHOSTUNREACH
          raise Error.from(ERROR_CODES[:CONNECTION_TIMEOUT])
        end

        def parse_json(body)
          return {} if body.nil? || body.empty?

          JSON.parse(body, symbolize_names: true)
        rescue JSON::ParserError
          {}
        end
      end
    end
  end
end
