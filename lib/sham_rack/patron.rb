require "patron"
require "sham_rack/registry"
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
      res = Patron::Response.new
      res.instance_variable_set(:@body, "hello World")
      # res.instance_variable_set(:@status, webmock_response.status[0])
      # res.instance_variable_set(:@status_line, webmock_response.status[1])
      # res.instance_variable_set(:@headers, webmock_response.headers)
      res
    end

    def create_rack_request(patron_request)
    end

    def rack_env(patron_request)
    end

    def patron_response(rack_response)
    end

  end

end