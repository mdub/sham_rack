ShamRack
========

ShamRack plumbs Net:HTTP into [Rack][rack].

What's it for, again?
---------------------

Well, you can _test your HTTP client code_, using ShamRack to stub out an external web-service. Think of it as [FakeWeb][fakeweb] on steriods.

Or, you can _test your Rack application_ (or Sinatra, or Rails, or Merb) using arbitrary HTTP client libraries, to check interoperability. For instance, you could hit a local app using:

* [`rest-client`][rest-client]
* [`httparty`][httparty]
* [`oauth`][oauth]

Installing it
-------------

    gem sources -a http://gems.github.com
    sudo gem install mdub-sham_rack

Using it
--------

### A simple inline application

    require 'sham_rack'

    ShamRack.at("www.example.com") do |env|
      ["200 OK", { "Content-type" => "text/plain" }, "Hello, world!"]
    end
      
    require 'open-uri'
    open("http://www.example.com/").read            #=> "Hello, world!"

### Sinatra integration

    ShamRack.at("sinatra.xyz").sinatra do
      get "/hello/:subject" do
        "Hello, #{params[:subject]}"
      end
    end

    open("http://sinatra.xyz/hello/stranger").read  #=> "Hello, stranger"

### Rackup support

    ShamRack.at("rackup.xyz").rackup do
      use Some::Middleware
      use Some::Other::Middleware
      run MyApp.new
    end

### Any old app

    ShamRack.mount(my_google_stub, "google.com")

What's the catch?
-----------------

* It's brand new! (there will be dragons)
* Your Rack request-handling code runs in the same Ruby VM, in fact the same Thread, as your request.

Thanks to
---------

* Blaine Cook for [FakeWeb][fakeweb], which was an inspiration for ShamRack.
* Perryn Fowler for his efforts plumbing Net::HTTP into ActionController::TestProcess.
* Christian Neukirchen et al for the chewy goodness that is [Rack][rack].

[rack]: http://rack.rubyforge.org/
[sinatra]: http://www.sinatrarb.com/
[rest-client]: http://github.com/adamwiggins/rest-client
[httparty]: http://github.com/jnunemaker/httparty
[oauth]: http://oauth.rubyforge.org/
[fakeweb]: http://fakeweb.rubyforge.org/
