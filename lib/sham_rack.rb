require "sham_rack/net_http"
require "sham_rack/registration"
require "sham_rack/version"

# ShamRack allows access to Rack applications using Net::Http, but without network traffic.
#
# For more detail, see http://github.com/mdub/sham_rack
#
module ShamRack
  extend ShamRack::Registration
end
