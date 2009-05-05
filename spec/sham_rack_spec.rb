require File.dirname(__FILE__) + '/spec_helper'

require "sham_rack"
require "open-uri"
require "restclient"
require "rack"

class PlainTextApp

  def call(env)
    [
      "200 OK", 
      {
        "Content-Type" => "text/plain",
        "Content-Length" => message.length.to_s
      }, 
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

class BiffFilter

  def initialize(app)
    @app = app
  end

  def call(env)
    status, headers, body = @app.call(env)
    upcased_body = Array(body).map { |x| x.upcase }
    [status, headers, upcased_body]
  end

end

describe ShamRack do

  after(:each) do
    ShamRack.unmount_all
  end

  describe "mounted Rack application" do
    
    before(:each) do
      ShamRack.mount(SimpleMessageApp.new("Hello, world"), "www.test.xyz")
    end

    it "can be accessed using Net::HTTP" do
      response = Net::HTTP.start("www.test.xyz") do |http|
        http.request(Net::HTTP::Get.new("/"))
      end
      response.body.should == "Hello, world"
    end
    
    it "can be accessed using open-uri" do
      response = open("http://www.test.xyz")
      response.status.should == ["200", "OK"]
      response.read.should == "Hello, world"
    end

    it "can be accessed using RestClient" do
      response = RestClient.get("http://www.test.xyz")
      response.code.should == 200
      response.to_s.should == "Hello, world"
    end

  end

  describe "#rackup" do

    it "mounts an app created using Rack::Builder" do
      ShamRack.rackup("rackup.xyz") do
        use BiffFilter
        run SimpleMessageApp.new("Racked!")
      end

      open("http://rackup.xyz").read.should == "RACKED!"
    end

  end

  describe "#lambda" do

    it "mounts associated block as an app" do
      ShamRack.lambda("simple.xyz") do |env|
        ["200 OK", { "Content-type" => "text/plain" }, "Easy, huh?"]
      end

      open("http://simple.xyz").read.should == "Easy, huh?"
    end

  end
  
  describe "#sinatra" do

    it "mounts associated block as a Sinatra app" do
      pending
      ShamRack.sinatra("sinatra.xyz") do
        get "/hello/:subject" do
          "Hello, #{params[:subject]}"
        end
      end

      open("http://sinatra.xyz/hello/stranger").read.should == "Hello, stranger"
    end

  end

  it "provides a valid Rack environment" do

    env_recorder = EnvRecordingApp.new
    
    ShamRack.rackup("env.xyz") do |env|
      use Rack::Lint
      run env_recorder
    end

    RestClient.get("http://env.xyz/blah?q=abc")

    env = env_recorder.last_env

    env["REQUEST_METHOD"].should == "GET"
    env["SCRIPT_NAME"].should == ""
    env["PATH_INFO"].should == "/blah"
    env["QUERY_STRING"].should == "q=abc"
    env["SERVER_NAME"].should == "env.xyz"
    env["SERVER_PORT"].should == "80"
    
    env["rack.version"].should == [0,1]
    env["rack.url_scheme"].should == "http"
    
    env["rack.multithread"].should == true
    env["rack.multiprocess"].should == true
    env["rack.run_once"].should == false

  end

  it "provides access to request headers" do
    
    ShamRack.lambda("env.xyz") do |env|
      @env = env
      ["200 OK", {}, ""]
    end

    Net::HTTP.start("env.xyz") do |http|
      request = Net::HTTP::Get.new("/")
      request["Foo-bar"] = "baz"
      http.request(request)
    end

    @env["HTTP_FOO_BAR"].should == "baz"
    
  end
  
end
