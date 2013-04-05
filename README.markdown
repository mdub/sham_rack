ShamRack [![Build Status](https://secure.travis-ci.org/mdub/sham_rack.png?branch=master)](http://travis-ci.org/mdub/sham_rack)
========

ShamRack plumbs HTTP requests into [Rack][rack].

What's it for, again?
---------------------

Well, it makes it easy to _stub out external (HTTP) services_, which is handy in development and testing environments, or when you want to _test your HTTP client code_.

You can also use it to _test your Rack application_ (or Sinatra, or Rails, or Merb) using a variety of HTTP client libraries, to check interoperability. For instance, you could test your app using:

* [`rest-client`][rest-client]
* [`httparty`][httparty]
* [`oauth`][oauth]

all without having to boot it in a server.

Installing it
-------------

    gem install sham_rack

Using it
--------

### A simple inline application

    require 'sham_rack'

    ShamRack.at("www.greetings.com") do |env|
      ["200 OK", { "Content-type" => "text/plain" }, ["Hello, world!"]]
    end
      
    require 'open-uri'
    open("http://www.greetings.com/").read            #=> "Hello, world!"

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

### Any old Rack app

    ShamRack.at("google.com").mount(my_google_stub) 

### General-purpose stubbing

    @stub_app = ShamRack.at("stubbed.com").stub
    @stub_app.register_resource("/greeting", "Hello, world!", "text/plain")
    
    open("http://stubbed.com/greeting").read       #=> "Hello, world!"
    @stub_app.last_request.path                    #=> "/greeting"

Or, just use Sinatra, as described above ... it's almost as succinct, and heaps more powerful.

### When you're done testing

    ShamRack.unmount_all

    open("http://stubbed.com/greeting").read       #=> OpenURI::HTTPError

Supported HTTP client libraries
-------------------------------

### Net::HTTP and friends

ShamRack supports requests made using Net::HTTP, or any of the numerous APIs built on top of it:

    uri = URI.parse("http://www.greetings.com/")
    Net::HTTP.get_response(uri).body                      #=> "Hello, world!"
    
    require 'open-uri'
    open("http://www.greetings.com/").read                #=> "Hello, world!"

    require 'restclient'
    RestClient.get("http://www.greetings.com/").to_s      #=> "Hello, world!"

    require 'mechanize'
    Mechanize.new.get("http://www.greetings.com/").body   #=> "Hello, world!"

### Patron (experimental)

We've recently added support for [Patron][patron]:

    require 'sham_rack/patron'

    patron = Patron::Session.new
    patron.get("http://www.greetings.com/").body          #=> "Hello, world!"

What's the catch?
-----------------

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
[mechanize]: http://mechanize.rubyforge.org
[patron]: http://github.com/toland/Patron
