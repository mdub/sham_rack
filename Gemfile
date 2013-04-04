source "http://rubygems.org"

gemspec

group :test do
  gem "rake"
  gem "rspec", "~> 2.13.0"
  gem "rr", "~> 1.0.5"
  gem "rack-test"
  gem "sinatra"
  gem "rest-client"
  gem "mechanize"
  gem "patron", ">= 0.4.16"
  if rack_version = ENV["RACK_VERSION"]
    gem "rack", rack_version
  end
end

