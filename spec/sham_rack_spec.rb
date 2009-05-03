require File.dirname(__FILE__) + '/spec_helper'

require "sham_rack"
require "open-uri"

describe ShamRack do
  
  describe "mounted echo app" do
    
    before(:all) do
      hello_app = lambda do |env| 
        ["200 OK", { "Content-type" => "text/plain" }, "Hello, world" ]
      end
      ShamRack.mount(hello_app, "www.test.xyz")
    end
    
    after(:all) do
      ShamRack.unmount_all
    end
    
    it "can be accessed using open-uri" do
      response = open("http://www.test.xyz")
      response.status[0].should == "200"
      response.read.should == "Hello, world"
    end
    
  end
  
end
