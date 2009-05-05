require File.dirname(__FILE__) + '/spec_helper'

require "sham_rack"
require "open-uri"
require "restclient"
require "rack"

class PlainApp

  def initialize(message)
    @message = message
  end

  def call(env)
    ["200 OK", { "Content-type" => "text/plain" }, @message.dup ]
  end

end

class BIFF

  def initialize(app)
    @app = app
  end

  def call(env)
    status, headers, body = @app.call(env)
    [status, headers, body.upcase]
  end

end

describe ShamRack do

  after(:each) do
    ShamRack.unmount_all
  end

  describe "mounted Rack application" do
    
    before(:each) do
      ShamRack.mount(PlainApp.new("Hello, world"), "www.test.xyz")
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
        use BIFF
        run PlainApp.new("Racked!")
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

  it "provides a Rack environment" do

    ShamRack.lambda("env.xyz") do |env|
      @env = env
      ["200 OK", {}, ""]
    end

    open("http://env.xyz/blah?q=abc")

    @env["REQUEST_METHOD"].should == "GET"
    @env["SCRIPT_NAME"].should == ""
    @env["PATH_INFO"].should == "/blah"
    @env["QUERY_STRING"].should == "q=abc"
    @env["SERVER_NAME"].should == "env.xyz"
    @env["SERVER_PORT"].should == "80"

    @env["rack.version"].should == [0,1]
    @env["rack.url_scheme"].should == "http"
    # rack.input: See below, the input stream.
    # rack.errors:  See below, the error stream.
    @env["rack.multithread"].should == true
    @env["rack.multiprocess"].should == true
    @env["rack.run_once"].should == false

  end

  it "provides access to request headers" do
    
    pending
    
    ShamRack.lambda("env.xyz") do |env|
      @env = env
      ["200 OK", {}, ""]
    end

  end
  
end
