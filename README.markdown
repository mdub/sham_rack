ShamRack
========

ShamRack plumbs Net:HTTP into [Rack][rack], providing infrastructure for testing arbitrary Rack-based apps using arbitrary HTTP clients, all from the comfort of your own Ruby VM.

What's it for, again?
---------------------

Well, you can _test your HTTP client code_, using ShamRack to fake out an external web-service ([Sinatra][sinatra] helps, here).

Or, you can `ShamRack.mount` your actual Sinatra/Rails/Merb/Rack app, which is handy if you want to _test access using an HTTP client library_ such as:

* [`rest-client`][rest-client]
* [`httparty`][httparty]
* [`oauth`][oauth]

Installing it
-------------

    gem sources -a http://gems.github.com
    sudo gem install mdub-sham_rack

Using it
--------

    require 'sham_rack'
    
    rack_app = lambda { |env| ["200 OK", { "Content-type" => "text/plain" }, "Hello, world!"] }
    ShamRack.mount(rack_app, "www.example.com")
      
    require 'open-uri'
    open("http://www.example.com/").read            #=> "Hello, world!"

### Sinatra integration

    ShamRack.sinatra("sinatra.xyz") do
      get "/hello/:subject" do
        "Hello, #{params[:subject]}"
      end
    end

    open("http://sinatra.xyz/hello/stranger").read  #=> "Hello, stranger"

### Rackup support

    ShamRack.rackup("rackup.xyz") do
      use Some::Middleware
      use Some::Other::Middleware
      run MyApp.new
    end

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
