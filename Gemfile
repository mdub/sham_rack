source "http://rubygems.org"

gemspec

group :test do
  gem "rake"
  gem "rspec", "~> 3.2.0"
  gem "rspec-mocks", "~> 3.2.1"
  gem "rack-test"
  gem "sinatra"
  gem "rest-client", "~> 1.8.0"
  gem "mechanize"
  gem "patron", ">= 0.4.16"
  if rack_version = ENV["RACK_VERSION"]
    gem "rack", rack_version
  end
end
