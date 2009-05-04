require "net/http"
require "sham_rack/registry"
require "sham_rack/http"

module Net

  def HTTP.new(address, port = HTTP.default_port, *proxy_args)
    rack_app = ShamRack.application_for(address, port)
    if rack_app
      ShamRack::HTTP.new(address, port, rack_app)
    else
      super
    end
  end

end
