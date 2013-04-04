module ShamRack

  module Registration

    ADDRESS_PATTERN = /^[a-z0-9-]+(\.[a-z0-9-]+)*$/i

    # deprecated
    def mount(app, address, port = nil)
      at(address, port).mount(app)
    end

    def unmount_all
      registry.clear
    end

    def at(address, port = nil, &app_block)
      registrar = Registrar.new(registry, resolve_mount_point(address, port))
      if app_block
        registrar.mount(app_block)
      else
        registrar
      end
    end

    def application_for(address, port = nil)
      registry[resolve_mount_point(address, port)]
    end

    private

    def registry
      @registry ||= {}
    end

    def resolve_mount_point(address, port = nil)
      unless address =~ ADDRESS_PATTERN
        raise ArgumentError, "invalid address"
      end
      port ||= Net::HTTP.default_port
      port = Integer(port)
      [address, port]
    end

  end

  class Registrar

    def initialize(registry, mount_point)
      @registry = registry
      @mount_point = mount_point
    end

    attr_reader :registry, :mount_point

    def mount(app)
      registry[mount_point] = app
    end

    alias run mount

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
