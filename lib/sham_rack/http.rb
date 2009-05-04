module ShamRack
  
  # a sham version of Net::HTTP
  class HTTP

    def initialize(address, port, rack_app)
      @address = address
      @port = @port
      @rack_app = rack_app
    end
    
    def start
      yield self
    end
    
    def request(*args)
      env = {}
      response = build_response(@rack_app.call(env))
      yield response if block_given?
      response
    end
    
    private
    
    def build_response(rack_response)
      status, headers, body = rack_response
      code, message = status.to_s.split(" ", 2)
      response = Net::HTTPResponse.send(:response_class, code).new("Sham", code, message)
      response.instance_variable_set(:@body, assemble_body(body))
      response.instance_variable_set(:@read, true)
      response.extend ShamRack::ResponseExtensions
      response
    end

    def assemble_body(body)
      content = ""
      body.each { |fragment| content << fragment }
      content
    end
    
  end
  
  module ResponseExtensions

    def read_body(dest = nil)
      yield @body if block_given?
      dest << @body if dest
      @body
    end
    
  end

end