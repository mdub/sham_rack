require "net/http"
require "sham_rack/registry"
require "sham_rack/http"

module Net

  def HTTP.new(address, port = nil, *proxy_args)
    port ||= HTTP.default_port
    rack_app = ShamRack.application_for(address, port)
    if rack_app
      ShamRack::HTTP.new(address, port, rack_app)
    else
      super(address, port, *proxy_args)
    end
  end

end
