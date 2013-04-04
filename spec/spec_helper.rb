require "rubygems"
require "rspec"
require "rr"

RSpec.configure do |config|
  config.mock_with RR::Adapters::RSpec2
end

require "test_apps"
