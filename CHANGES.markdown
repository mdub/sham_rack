## 5-Jun-2009 [mdub@dogbiscuit.org]

* Add support for Net::HTTP.get_response.
* Pass back headers provided by Rack app in the HTTPResponse.

## 3-Jun-2009 [mdub@dogbiscuit.org]

* Introduced ShamRack#at to simplify registration of apps.

## 13-May-2009 [mdub@dogbiscuit.org]

* Added accessors on HTTP object for address, port and rack_app.
* Added accessors to imitate "net/https".
