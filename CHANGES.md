## 1.4.1 (20-Aug-2017)

* Add support for `Net::HTTPRequest#body_stream`, and with it, newer versions of rest-client.

## 1.4.0 (6-Jan-2017)

* Add support for `ShamRack.allow_network_connections`.
* Remove support for `ShamRack.mount`.

## 1.3.6 (5-Apr-2013)

* Deprecate `ShamRack.mount` in favour of `ShamRack.at(...).mount`.

## 1.3.5 (25-Mar-2013)

* Ensure an HTTP status "message" is set.

## 1.3.4 (1-May-2012)

* Validate arguments to `ShamRack.mount`.
* Update for compatibility with patron-0.4.x.

## 1.3.3 (22-Dec-2010)

* Add support for Patron.

## 1.3.2 (02-Sep-2010)

* Fixes to support Ruby-1.9.x.

## 1.3.1 (12-Jul-2010)

* Add support for Mechanize [jyurek@thoughtbot.com].

## 1.3.0 (11-Mar-2010)

* Added generic `StubWebService`.

## 1.2.1 (15-Jan-2010)

* Fix an incompatibility with rest-client 1.2.0 [jeremy.burks@gmail.com].

## 1.2.0 (27-Nov-2009)

* Change of approach: extend rather than reimplement `Net:HTTP`.  This should improve coverage of all the weird and wonderful ways of using the `Net:HTTP` API.

## 1.1.2 (5-Jun-2009)

* Add support for `Net::HTTP.get_response`.
* Pass back headers provided by Rack app in the `HTTPResponse`.
* Introduced `ShamRack.at` to simplify registration of apps.

## 1.1.1 (2-Jun-2009)

* Added accessors on HTTP object for address, port and rack_app.
* Added accessors to imitate "net/https".
