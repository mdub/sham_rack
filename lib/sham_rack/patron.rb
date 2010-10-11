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
      res.body = "Hello World"
      res
    end

  end

end