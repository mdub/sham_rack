require "httpclient"
require "sham_rack"
require "uri"

class HTTPClient

  class SessionManager

    private

    alias :open_without_sham_rack :open

    def open(uri, via_proxy = false)
      site = Site.new(uri)
      rack_app = ShamRack.application_for(site.host, site.port)
      if rack_app
        ShamSession.new(site, rack_app)
      else
        open_without_sham_rack(uri, via_proxy)
      end
    end

  end

  class ShamSession

    attr_accessor :ssl_peer_cert

    def initialize(site, rack_app)
      @site = site
      @rack_app = rack_app
    end

    def dest
      @site
    end

    def query(req)
      @rack_response = @rack_app.call(rack_env(req))
    end

    def get_header
      status, headers, _body = @rack_response
      reason ||= Rack::Utils::HTTP_STATUS_CODES[status.to_i]
      ["HTTP/1.1", status, reason, {}]
    end

    def get_body
      _status, _headers, body = @rack_response
      body.each do |part|
        yield part
      end
    end

    def close
      @closed = true
    end

    def closed?
      @closed
    end

    private

    def rack_env(req)
      {}
    end

  end

end
