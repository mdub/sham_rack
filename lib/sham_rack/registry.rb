module ShamRack

  module Registry
  
    def mount(rack_app, address, port = Net::HTTP.default_port)
      registry[[address, port]] = rack_app
    end
    
    def rackup(address, port = Net::HTTP.default_port, &block)
      app = Rack::Builder.new(&block).to_app
      mount(app, address, port)
    end
    
    def lambda(address, port = Net::HTTP.default_port, &block)
      mount(block, address, port)
    end
    
    def sinatra(address, port = Net::HTTP.default_port, &block)
      require "sinatra/base"
      sinatra_app = Class.new(Sinatra::Base)
      sinatra_app.class_eval(&block)
      mount(sinatra_app.new, address, port)
    end

    def unmount_all
      registry.clear
    end
    
    def application_for(address, port = Net::HTTP.default_port)
      registry[[address, port]]
    end

    private
    
    def registry
      @registry ||= {}
    end
    
  end
    
  extend Registry

end
