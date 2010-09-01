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

      def request(req, body = nil)
        env = default_env
        env.merge!(path_env(req.path))
        env.merge!(method_env(req))
        env.merge!(header_env(req))
        env.merge!(io_env(req, body))
        response = build_response(@rack_app.call(env))
        yield response if block_given?
        return response
      end

      private

      def default_env
        {
          "SCRIPT_NAME" => "",
          "SERVER_NAME" => @address,
          "SERVER_PORT" => @port.to_s,   
          "rack.version" => [0,1],
          "rack.url_scheme" => "http",
          "rack.multithread" => true,
          "rack.multiprocess" => true,
          "rack.run_once" => false
        }
      end

      def method_env(request)
        {
          "REQUEST_METHOD" => request.method
        }
      end

      def io_env(request, body)
        raise(ArgumentError, "both request.body and body argument were provided") if (request.body && body)
        body ||= request.body || ""
        body = body.to_s
        body = body.encode("ASCII-8BIT") if body.respond_to?(:encode)
        { 
          "rack.input" => StringIO.new(body),
          "rack.errors" => $stderr
        }
      end

      def path_env(path)
        uri = URI.parse(path)
        {
          "PATH_INFO" => uri.path,
          "QUERY_STRING" => (uri.query || ""),
        }
      end

      def header_env(request)
        result = {}
        request.each do |header, content|
          result["HTTP_" + header.upcase.gsub('-', '_')] = content
        end
        %w(TYPE LENGTH).each do |x|
          result["CONTENT_#{x}"] = result.delete("HTTP_CONTENT_#{x}") if result.has_key?("HTTP_CONTENT_#{x}")
        end
        return result
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
        return content
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
