require "net/http"
require "rack"

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
        body ||= request_body(request)
        Rack::MockRequest.env_for(request.path, :method => request.method, :input => body)
      end

      def request_body(request)
        return request.body unless request.body.nil?
        return request.body_stream.read unless request.body_stream.nil?
        ""
      end

      def build_response(rack_response)
        status, headers, body = rack_response
        code, message = status.to_s.split(" ", 2)
        message ||= Rack::Utils::HTTP_STATUS_CODES[code.to_i]
        response = Net::HTTPResponse.send(:response_class, code).new("Sham", code, message)
        response.instance_variable_set(:@rack_body, body)
        headers.each do |k,v|
          response.add_field(k, v)
        end
        response.extend ShamRack::NetHttp::ResponseExtensions
        return response
      end

    end

    module ResponseExtensions

      def read_body(dest = nil, &block)
        out = procdest(dest, block)
        @rack_body.each do |fragment|
          out << fragment
        end
        out
      end
    end

  end

end
