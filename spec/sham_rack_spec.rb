require "spec_helper"

require "sham_rack"
require "sham_rack/patron"
require "open-uri"
require "restclient"
require "mechanize"
require "rack"

describe ShamRack do

  after(:each) do
    ShamRack.unmount_all
  end

  describe "mounted Rack application" do

    before(:each) do
      ShamRack.mount(GreetingApp.new, "www.greetings.com")
    end

    it "can be accessed using Net::HTTP" do
      response = Net::HTTP.start("www.greetings.com") do |http|
        http.request(Net::HTTP::Get.new("/"))
      end
      response.body.should == "Hello, world"
    end

    it "can be accessed using Net::HTTP#get_response" do
      response = Net::HTTP.get_response(URI.parse("http://www.greetings.com/"))
      response.body.should == "Hello, world"
    end

    it "can be accessed using open-uri" do
      response = open("http://www.greetings.com")
      response.status.should == ["200", "OK"]
      response.read.should == "Hello, world"
    end

    it "can be accessed using RestClient" do
      response = RestClient.get("http://www.greetings.com")
      response.code.should == 200
      response.to_s.should == "Hello, world"
    end

    it "can be accessed using Mechanize" do
      response = Mechanize.new.get("http://www.greetings.com")
      response.body.should == "Hello, world"
    end

    it "can be accessed using Patron" do
      patron = Patron::Session.new
      response = patron.get("http://www.greetings.com/foo/bar")
      response.body.should == "Hello, world"
    end

  end

  describe ".at" do

    describe "with a block" do

      it "mounts associated block as an app" do

        ShamRack.at("simple.xyz") do |env|
          ["200 OK", { "Content-type" => "text/plain" }, ["Easy, huh?"]]
        end

        open("http://simple.xyz").read.should == "Easy, huh?"

      end

    end

    describe "#rackup" do

      before do
        @return_value = ShamRack.at("rackup.xyz").rackup do
          use UpcaseBody
          run GreetingApp.new
        end
      end

      it "mounts an app created using Rack::Builder" do
        open("http://rackup.xyz").read.should == "HELLO, WORLD"
      end

      it "returns the app" do
        @return_value.should respond_to(:call)
      end

    end

    describe "#sinatra" do

      before do
        @return_value = ShamRack.at("sinatra.xyz").sinatra do
          get "/hello/:subject" do
            "Hello, #{params[:subject]}"
          end
        end
      end
      
      it "mounts associated block as a Sinatra app" do
        open("http://sinatra.xyz/hello/stranger").read.should == "Hello, stranger"
      end

      it "returns the app" do
        @return_value.should respond_to(:call)
      end
      
    end

    describe "#stub" do
      
      before do
        @return_value = ShamRack.at("stubbed.xyz").stub
      end

      it "mounts a StubWebService" do
        ShamRack.application_for("stubbed.xyz").should be_kind_of(ShamRack::StubWebService)
      end
      
      it "returns the StubWebService" do
        @return_value.should == ShamRack.application_for("stubbed.xyz")
      end
      
    end
    
  end

  describe "response" do
    
    before(:each) do
      ShamRack.at("www.greetings.com") do
        [
          "201 Created", 
          { "Content-Type" => "text/plain", "X-Foo" => "bar" },
          ["BODY"]
        ]
      end
      @response = Net::HTTP.get_response(URI.parse("http://www.greetings.com/"))
    end
    
    it "has status returned by app" do
      @response.code.should == "201"
    end

    it "has body returned by app" do
      @response.body.should == "BODY"
    end
    
    it "has Content-Type returned by app" do
      @response.content_type.should == "text/plain"
    end
    
    it "has other headers returned by app" do
      @response["x-foo"].should =="bar"
    end
    
  end
  
  describe "Rack environment" do

    before(:each) do
      @env_recorder = recorder = EnvRecorder.new(GreetingApp.new)
      ShamRack.at("env.xyz").rackup do
        use Rack::Lint
        run recorder
      end
    end

    def env
      @env_recorder.last_env
    end

    it "is valid" do

      open("http://env.xyz/blah?q=abc")

      env["REQUEST_METHOD"].should == "GET"
      env["SCRIPT_NAME"].should == ""
      env["PATH_INFO"].should == "/blah"
      env["QUERY_STRING"].should == "q=abc"
      env["SERVER_NAME"].should == "env.xyz"
      env["SERVER_PORT"].should == "80"

      env["rack.version"].should be_kind_of(Array)
      env["rack.url_scheme"].should == "http"

      env["rack.multithread"].should == true
      env["rack.multiprocess"].should == true
      env["rack.run_once"].should == false

    end

    it "provides request headers" do

      Net::HTTP.start("env.xyz") do |http|
        request = Net::HTTP::Get.new("/")
        request["Foo-bar"] = "baz"
        http.request(request)
      end

      env["HTTP_FOO_BAR"].should == "baz"

    end

    it "supports POST" do

      RestClient.post("http://env.xyz/resource", "q" => "rack")

      env["REQUEST_METHOD"].should == "POST"
      env["CONTENT_TYPE"].should == "application/x-www-form-urlencoded"
      env["rack.input"].read.should == "q=rack"

    end

    it "supports POST using Net::HTTP" do

      Net::HTTP.start("env.xyz") do |http|
        http.post("/resource", "q=rack")
      end

      env["REQUEST_METHOD"].should == "POST"
      env["rack.input"].read.should == "q=rack"

    end

    it "supports POST using Patron" do

      patron = Patron::Session.new
      response = patron.post("http://env.xyz/resource", "<xml/>", "Content-Type" => "application/xml")

      response.status.should == "200 OK"
      
      env["REQUEST_METHOD"].should == "POST"
      env["rack.input"].read.should == "<xml/>"
      env["CONTENT_TYPE"].should == "application/xml"

    end

    it "supports PUT" do

      RestClient.put("http://env.xyz/thing1", "stuff", :content_type => "text/plain")

      env["REQUEST_METHOD"].should == "PUT"
      env["CONTENT_TYPE"].should == "text/plain"
      env["rack.input"].read.should == "stuff"

    end

    it "supports PUT using Patron" do

      patron = Patron::Session.new
      response = patron.put("http://env.xyz/resource", "stuff", "Content-Type" => "text/plain")

      env["REQUEST_METHOD"].should == "PUT"
      env["CONTENT_TYPE"].should == "text/plain"
      env["rack.input"].read.should == "stuff"

    end

    it "supports DELETE" do

      RestClient.delete("http://env.xyz/thing/1")

      env["REQUEST_METHOD"].should == "DELETE"
      env["PATH_INFO"].should == "/thing/1"

    end

    it "supports DELETE using Patron" do

      patron = Patron::Session.new
      response = patron.delete("http://env.xyz/resource")

      env["REQUEST_METHOD"].should == "DELETE"
      env["PATH_INFO"].should == "/resource"

    end

  end

end
