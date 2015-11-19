require "spec_helper"

require "sham_rack"
require "sham_rack/patron"
require "open-uri"
require "restclient"
require "mechanize"
require "rack"

RSpec.describe ShamRack do

  class NetHttpProhibited < StandardError; end

  before do
    allow_any_instance_of(Net::HTTP).to receive(:start) do
      raise NetHttpProhibited, "real network calls are not allowed"
    end
  end

  after(:each) do
    ShamRack.reset
  end

  describe "mounted Rack application" do

    before(:each) do
      ShamRack.at("www.greetings.com").mount(GreetingApp.new)
    end

    it "can be accessed using Net::HTTP" do
      response = Net::HTTP.start("www.greetings.com") do |http|
        http.request(Net::HTTP::Get.new("/"))
      end
      expect(response.body).to eq("Hello, world")
    end

    it "can be accessed using Net::HTTP#get_response" do
      response = Net::HTTP.get_response(URI.parse("http://www.greetings.com/"))
      expect(response.body).to eq("Hello, world")
    end

    it "can be accessed using open-uri" do
      response = open("http://www.greetings.com")
      expect(response.status).to eq(["200", "OK"])
      expect(response.read).to eq("Hello, world")
    end

    it "can be accessed using RestClient" do
      response = RestClient.get("http://www.greetings.com")
      expect(response.code).to eq(200)
      expect(response.to_s).to eq("Hello, world")
    end

    it "can be accessed using Mechanize" do
      response = Mechanize.new.get("http://www.greetings.com")
      expect(response.body).to eq("Hello, world")
    end

    it "can be accessed using Patron" do
      patron = Patron::Session.new
      response = patron.get("http://www.greetings.com/foo/bar")
      expect(response.body).to eq("Hello, world")
    end

  end

  describe ".at" do

    context "with a block" do

      it "mounts associated block as an app" do

        ShamRack.at("simple.xyz") do |env|
          ["200 OK", { "Content-type" => "text/plain" }, ["Easy, huh?"]]
        end

        expect(open("http://simple.xyz").read).to eq("Easy, huh?")

      end

    end

    context "with a URL" do

      it "raises an ArgumentError" do
        expect do
          ShamRack.at("http://www.greetings.com")
        end.to raise_error(ArgumentError, "invalid address")
      end

    end

    describe "#mount" do

      it "mounts an app" do

        ShamRack.at("hello.xyz").mount(GreetingApp.new)

        expect(open("http://hello.xyz").read).to eq("Hello, world")

      end

    end

    describe "#unmount" do

      it "deregisters a mounted app" do

        ShamRack.at("gone.xyz").mount(GreetingApp.new)
        ShamRack.at("gone.xyz").unmount

        expect do
          open("http://gone.xyz").read
        end.to raise_error(NetHttpProhibited)

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
        expect(open("http://rackup.xyz").read).to eq("HELLO, WORLD")
      end

      it "returns the app" do
        expect(@return_value).to respond_to(:call)
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
        expect(open("http://sinatra.xyz/hello/stranger").read).to eq("Hello, stranger")
      end

      it "returns the app" do
        expect(@return_value).to respond_to(:call)
      end

    end

    describe "#stub" do

      before do
        @return_value = ShamRack.at("stubbed.xyz").stub
      end

      it "mounts a StubWebService" do
        expect(ShamRack.application_for("stubbed.xyz")).to be_kind_of(ShamRack::StubWebService)
      end

      it "returns the StubWebService" do
        expect(@return_value).to eq(ShamRack.application_for("stubbed.xyz"))
      end

    end

  end

  describe "response" do

    before(:each) do
      ShamRack.at("www.greetings.com") do
        [
          "456 Foo Bar",
          { "Content-Type" => "text/plain", "X-Foo" => "bar" },
          ["BODY"]
        ]
      end
    end

    let(:response) { Net::HTTP.get_response(URI.parse("http://www.greetings.com/")) }

    it "has status returned by app" do
      expect(response.code).to eq("456")
    end

    it "has status message returned by app" do
      expect(response.message).to eq("Foo Bar")
    end

    it "has body returned by app" do
      expect(response.body).to eq("BODY")
    end

    it "has Content-Type returned by app" do
      expect(response.content_type).to eq("text/plain")
    end

    it "has other headers returned by app" do
      expect(response["x-foo"]).to eq("bar")
    end

    context "when the app returns a numeric status" do

      before(:each) do
        ShamRack.at("www.greetings.com") do
          [
            201,
            { "Content-Type" => "text/plain" },
            ["BODY"]
          ]
        end
        @response = Net::HTTP.get_response(URI.parse("http://www.greetings.com/"))
      end

      it "has status returned by app" do
        expect(response.code).to eq("201")
      end

      it "derives a status message" do
        expect(response.message).to eq("Created")
      end

    end

  end

  describe ".allow_network_connections" do

    context "when false" do

      before do
        ShamRack.prevent_network_connections
      end

      after do
        ShamRack.allow_network_connections
      end

      it "prevents Net::HTTP requests" do
        expect {
          Net::HTTP.get_response(URI.parse("http://www.example.com/"))
        }.to raise_error(ShamRack::NetworkConnectionPrevented)
      end

      it "prevents Patron requests" do
        expect {
          Patron::Session.new.get("http://www.example.com/")
        }.to raise_error(ShamRack::NetworkConnectionPrevented)
      end

    end

    context "when true" do

      before do
        ShamRack.allow_network_connections
      end

      it "allows Net::HTTP requests" do
        expect {
          Net::HTTP.get_response(URI.parse("http://www.example.com/"))
        }.to raise_error(NetHttpProhibited)
      end

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

      expect(env["REQUEST_METHOD"]).to eq("GET")
      expect(env["SCRIPT_NAME"]).to eq("")
      expect(env["PATH_INFO"]).to eq("/blah")
      expect(env["QUERY_STRING"]).to eq("q=abc")
      expect(env["SERVER_NAME"]).to eq("env.xyz")
      expect(env["SERVER_PORT"]).to eq("80")

      expect(env["rack.version"]).to be_kind_of(Array)
      expect(env["rack.url_scheme"]).to eq("http")

      expect(env["rack.multithread"]).to eq(true)
      expect(env["rack.multiprocess"]).to eq(true)
      expect(env["rack.run_once"]).to eq(false)

    end

    it "provides request headers" do

      Net::HTTP.start("env.xyz") do |http|
        request = Net::HTTP::Get.new("/")
        request["Foo-bar"] = "baz"
        http.request(request)
      end

      expect(env["HTTP_FOO_BAR"]).to eq("baz")

    end

    it "supports POST" do

      RestClient.post("http://env.xyz/resource", "q" => "rack")

      expect(env["REQUEST_METHOD"]).to eq("POST")
      expect(env["CONTENT_TYPE"]).to eq("application/x-www-form-urlencoded")
      expect(env["rack.input"].read).to eq("q=rack")

    end

    it "supports POST using Net::HTTP" do

      Net::HTTP.start("env.xyz") do |http|
        http.post("/resource", "q=rack")
      end

      expect(env["REQUEST_METHOD"]).to eq("POST")
      expect(env["rack.input"].read).to eq("q=rack")

    end

    it "supports POST using Patron" do

      patron = Patron::Session.new
      response = patron.post("http://env.xyz/resource", "<xml/>", "Content-Type" => "application/xml")

      expect(response.status).to eq(200)

      expect(env["REQUEST_METHOD"]).to eq("POST")
      expect(env["rack.input"].read).to eq("<xml/>")
      expect(env["CONTENT_TYPE"]).to eq("application/xml")

    end

    it "supports PUT" do

      RestClient.put("http://env.xyz/thing1", "stuff", :content_type => "text/plain")

      expect(env["REQUEST_METHOD"]).to eq("PUT")
      expect(env["CONTENT_TYPE"]).to eq("text/plain")
      expect(env["rack.input"].read).to eq("stuff")

    end

    it "supports PUT using Patron" do

      patron = Patron::Session.new
      response = patron.put("http://env.xyz/resource", "stuff", "Content-Type" => "text/plain")

      expect(env["REQUEST_METHOD"]).to eq("PUT")
      expect(env["CONTENT_TYPE"]).to eq("text/plain")
      expect(env["rack.input"].read).to eq("stuff")

    end

    it "supports DELETE" do

      RestClient.delete("http://env.xyz/thing/1")

      expect(env["REQUEST_METHOD"]).to eq("DELETE")
      expect(env["PATH_INFO"]).to eq("/thing/1")

    end

    it "supports DELETE using Patron" do

      patron = Patron::Session.new
      response = patron.delete("http://env.xyz/resource")

      expect(env["REQUEST_METHOD"]).to eq("DELETE")
      expect(env["PATH_INFO"]).to eq("/resource")

    end

  end

end
