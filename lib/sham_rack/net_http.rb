require "net/http"
require "sham_rack/registry"

class << Net::HTTP  

  alias :new_without_sham_rack :new
  
  def new(address, port = nil, *proxy_args)
    port ||= Net::HTTP.default_port
    rack_app = ShamRack.application_for(address, port)
    http_object = new_without_sham_rack(address, port, *proxy_args)
    if rack_app
      http_object.extend(ShamRack::NetHttp::Extensions)
      http_object.rack_app = rack_app
    end
    http_object
  end

end

module ShamRack
  module NetHttp
    
    module Extensions

      attr_accessor :rack_app

      def start
        if block_given?
          yield self 
        else
          self
        end
      end

      def request(request, body = nil)
        rack_response = @rack_app.call(rack_env(request, body))
        net_http_response = build_response(rack_response)
        yield net_http_response if block_given?
        return net_http_response
      end

      private

      def rack_env(request, body)
        rack_env = request_env(request, body)
        rack_env.merge!(header_env(request))
        rack_env.merge!(server_env)
      end
      
      def server_env
        {
          "SERVER_NAME" => @address, 
          "SERVER_PORT" => @port.to_s
        }
      end
      
      def header_env(request)
        env = {}
        request.each_header do |header, content|
          key = header.upcase.gsub('-', '_')
          key = "HTTP_" + key unless key =~ /^CONTENT_(TYPE|LENGTH)$/
          env[key] = content
        end
        env
      end

      def request_env(request, body)
        body ||= request.body || ""
        Rack::MockRequest.env_for(request.path, :method => request.method, :input => body.to_s)
      end

      def build_response(rack_response)
        status, headers, body = rack_response
        code, message = status.to_s.split(" ", 2)
        response = Net::HTTPResponse.send(:response_class, code).new("Sham", code, message)
        response.instance_variable_set(:@body, assemble_body(body))
        response.instance_variable_set(:@read, true)
        headers.each do |k,v|
          response.add_field(k, v)
        end
        response.extend ShamRack::NetHttp::ResponseExtensions
        return response
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
        return @body
      end

    end

  end

end
