source "http://rubygems.org"

gemspec

group :test do
  gem "rake"
  gem "rspec", "~> 1.3.1"
  gem "rr", "~> 1.0"
  gem "rack-test"
  gem "sinatra"
  gem "rest-client"
  gem "mechanize"
  gem "patron", ">= 0.4.16"
  if rack_version = ENV["RACK_VERSION"]
    gem "rack", rack_version
  end
end

