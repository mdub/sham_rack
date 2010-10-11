require "rubygems"
require "spec"
require "rr"

Spec::Runner.configure do |config|
  config.mock_with RR::Adapters::Rspec
end

require "test_apps"
