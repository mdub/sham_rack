require File.dirname(__FILE__) + '/spec_helper'

require "sham_rack"
require "open-uri"
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

  describe "#mount" do

    it "makes a Rack application accessible using Net::HTTP" do
      ShamRack.mount(PlainApp.new("Hello, world"), "www.test.xyz")

      response = open("http://www.test.xyz")
      response.status.should == ["200", "OK"]
      response.read.should == "Hello, world"
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

  describe "Rack environment" do
    
    before(:all) do
      rack_environment = nil
      ShamRack.lambda("env.xyz") do |env|
        @env = env
        ["200 OK", {}, ""]
      end

      open("http://env.xyz/blah?q=abc")
    end

    it "provides REQUEST_METHOD" do
      @env["REQUEST_METHOD"].should == "GET"
    end

    it "provides (empty) SCRIPT_NAME" do
      @env["SCRIPT_NAME"].should == ""
    end

    it "provides PATH_INFO" do
      @env["PATH_INFO"].should == "/blah"
    end
    
    it "provides QUERY_STRING" do
      @env["QUERY_STRING"].should == "q=abc"
    end

    it "provides SERVER_NAME" do
      @env["SERVER_NAME"].should == "env.xyz"
    end
    
    it "provides SERVER_PORT" do
      @env["SERVER_PORT"].should == "80"
    end

# QUERY_STRING: The portion of the request URL that follows the ?, if any. May be empty, but is always required!
# SERVER_NAME, SERVER_PORT: When combined with SCRIPT_NAME and PATH_INFO, these variables can be used to complete the URL. Note, however, that HTTP_HOST, if present, should be used in preference to SERVER_NAME for reconstructing the request URL. SERVER_NAME and SERVER_PORT can never be empty strings, and so are always required.

    
  end

end
