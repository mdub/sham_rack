module ShamRack

  class << self

    def network_connections_allowed?
      @allow_network_connections
    end

    def allow_network_connections
      @allow_network_connections = true
    end

    def prevent_network_connections
      @allow_network_connections = false
    end

  end

  class NetworkConnectionPrevented < StandardError
  end

end

ShamRack.allow_network_connections
