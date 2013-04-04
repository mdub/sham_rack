require "patron"
require "sham_rack"
require "uri"

module Patron

  class Session

    alias :handle_request_without_sham_rack :handle_request

    def handle_request(patron_request)
      uri = URI.parse(patron_request.url)
      rack_app = ShamRack.application_for(uri.host, uri.port)
      if rack_app
        handle_request_with_rack(patron_request, rack_app)
      else
        handle_request_without_sham_rack(patron_request)
      end
    end

    private

    def handle_request_with_rack(patron_request, rack_app)
      env = rack_env_for(patron_request)
      rack_response = rack_app.call(env)
      patron_response(rack_response)
    end

    def rack_env_for(patron_request)
      env = Rack::MockRequest.env_for(patron_request.url, :method => patron_request.action, :input => patron_request.upload_data)
      env.merge!(header_env(patron_request))
      env
    end

    def patron_response(rack_response)
      status, headers, body = rack_response
      Patron::Response.new("", status.to_i, 0, assemble_headers(status, headers), assemble_body(body))
    end

    def header_env(patron_request)
      env = {}
      patron_request.headers.each do |header, content|
        key = header.upcase.gsub('-', '_')
        key = "HTTP_" + key unless key =~ /^CONTENT_(TYPE|LENGTH)$/
        env[key] = content
      end
      env
    end

    def assemble_headers(status, headers)
      status_code = Rack::Utils::HTTP_STATUS_CODES[status.to_i]
      content = "HTTP/1.1 #{status} #{status_code}\r\n"
      headers.each do |k, v|
        content << "#{k}: #{v}\r\n"
      end
      content
    end

    def assemble_body(body)
      content = ""
      body.each { |fragment| content << fragment }
      content
    end

  end

end
