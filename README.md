ShamRack
========

[![Gem Version](https://badge.fury.io/rb/sham_rack.svg)](https://badge.fury.io/rb/sham_rack)
[![Build Status](https://travis-ci.org/mdub/sham_rack.svg?branch=master)](https://travis-ci.org/mdub/sham_rack)

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

```ruby
require 'sham_rack'

ShamRack.at("www.greetings.com") do |env|
  ["200 OK", { "Content-type" => "text/plain" }, ["Hello, world!"]]
end

require 'open-uri'
open("http://www.greetings.com/").read            #=> "Hello, world!"
```

### Sinatra integration

```ruby
ShamRack.at("sinatra.xyz").sinatra do
  get "/hello/:subject" do
    "Hello, #{params[:subject]}"
  end
end

open("http://sinatra.xyz/hello/stranger").read  #=> "Hello, stranger"
```
### Rackup support

```ruby
ShamRack.at("rackup.xyz").rackup do
  use Some::Middleware
  use Some::Other::Middleware
  run MyApp.new
end
```

### Any old Rack app

```ruby
ShamRack.at("google.com").mount(my_google_stub)
```

### General-purpose stubbing

```ruby
@stub_app = ShamRack.at("stubbed.com").stub
@stub_app.register_resource("/greeting", "Hello, world!", "text/plain")

open("http://stubbed.com/greeting").read       #=> "Hello, world!"
@stub_app.last_request.path                    #=> "/greeting"
```

### On a specific port

```ruby
ShamRack.at("example.com", 8080) do |env|
  ["200 OK", { "Content-type" => "text/plain" }, ["Hello, world!"]]
end
```

Or, just use Sinatra, as described above ... it's almost as succinct, and heaps more powerful.

### Avoiding (accidental) real network connections

```ruby
ShamRack.prevent_network_connections
```

### When you're done testing

```ruby
ShamRack.reset

open("http://stubbed.com/greeting").read       #=> OpenURI::HTTPError
```

Supported HTTP client libraries
-------------------------------

### Net::HTTP and friends

ShamRack supports requests made using Net::HTTP, or any of the numerous APIs built on top of it:

```ruby
uri = URI.parse("http://www.greetings.com/")
Net::HTTP.get_response(uri).body                      #=> "Hello, world!"

require 'open-uri'
open("http://www.greetings.com/").read                #=> "Hello, world!"

require 'restclient'
RestClient.get("http://www.greetings.com/").to_s      #=> "Hello, world!"

require 'mechanize'
Mechanize.new.get("http://www.greetings.com/").body   #=> "Hello, world!"
```

### Patron (experimental)

We've recently added support for [Patron][patron]:

```ruby
require 'sham_rack/patron'

patron = Patron::Session.new
patron.get("http://www.greetings.com/").body          #=> "Hello, world!"
```

What's the catch?
-----------------

* Your Rack request-handling code runs in the same Ruby VM, in fact the same Thread, as your request.

Thanks to
---------

* Blaine Cook for [FakeWeb][fakeweb], which was an inspiration for ShamRack.
* Perryn Fowler for his efforts plumbing Net::HTTP into ActionController::TestProcess.
* Leah Neukirchen et al for the chewy goodness that is [Rack][rack].

[rack]: http://github.com/rack/rack
[sinatra]: http://www.sinatrarb.com/
[rest-client]: https://github.com/adamwiggins/rest-client
[httparty]: https://github.com/jnunemaker/httparty
[oauth]: https://github.com/oauth-xx/oauth-ruby
[fakeweb]: https://github.com/chrisk/fakeweb
[mechanize]: https://github.com/sparklemotion/mechanize
[patron]: https://github.com/toland/Patron
