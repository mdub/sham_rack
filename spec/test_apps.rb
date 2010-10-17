require "rack"

class GreetingApp

  include Rack::Utils
  
  def call(env)
    params = parse_nested_query(env["QUERY_STRING"])
    salutation = params[:salutation] || "Hello"
    subject = params[:subject] || "world"
    message = "#{salutation}, #{subject}"
    [
      "200 OK", 
      { "Content-Type" => "text/plain", "Content-Length" => message.length.to_s },
      [message]
    ]
  end
  
end

class EnvRecorder

  def initialize(app)
    @app = app
  end
  
  def call(env)
    @last_env = env
    @app.call(env)
  end

  attr_reader :last_env

end

class UpcaseBody

  def initialize(app)
    @app = app
  end

  def call(env)
    status, headers, body = @app.call(env)
    upcased_body = Array(body).map { |x| x.upcase }
    [status, headers, upcased_body]
  end

end
