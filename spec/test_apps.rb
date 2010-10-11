class PlainTextApp

  def call(env)
    [
      "200 OK", 
      { "Content-Type" => "text/plain", "Content-Length" => message.length.to_s },
      [message]
    ]
  end

end

class SimpleMessageApp < PlainTextApp

  def initialize(message)
    @message = message
  end

  attr_reader :message

end

class EnvRecordingApp < PlainTextApp

  def call(env)
    @last_env = env
    super
  end

  attr_reader :last_env

  def message
    "env stored for later perusal"
  end

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
