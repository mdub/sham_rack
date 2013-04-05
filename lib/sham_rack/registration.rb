module ShamRack

  module Registration

    ADDRESS_PATTERN = /^[a-z0-9-]+(\.[a-z0-9-]+)*$/i

    def unmount_all
      registry.clear
    end

    def at(address, port = nil, &app_block)
      mount_point = mount_point_for(address, port)
      if app_block
        mount_point.mount(app_block)
      else
        mount_point
      end
    end

    def application_for(address, port = nil)
      mount_point_for(address, port).app
    end

    def mount(app, address, port = nil)
      at(address, port).mount(app)
    end

    private

    def mount_point_for(address, port)
      registry[mount_key(address, port)]
    end

    def registry
      @registry ||= Hash.new do |hash, key|
        hash[key] = MountPoint.new
      end
    end

    def mount_key(address, port)
      unless address =~ ADDRESS_PATTERN
        raise ArgumentError, "invalid address"
      end
      port ||= Net::HTTP.default_port
      port = Integer(port)
      [address, port]
    end

  end

  class MountPoint

    attr_reader :app

    def mount(app)
      @app = app
    end

    def unmount
      @app = nil
    end

    def rackup(&block)
      require "rack"
      mount(Rack::Builder.new(&block).to_app)
    end

    def sinatra(&block)
      require "sinatra/base"
      sinatra_app = Class.new(Sinatra::Base)
      sinatra_app.class_eval(&block)
      mount(sinatra_app.new)
    end

    def stub
      require "sham_rack/stub_web_service"
      mount(StubWebService.new)
    end

  end

end
