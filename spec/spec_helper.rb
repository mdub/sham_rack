require "rubygems"
require "rspec"
require "rr"

RSpec.configure do |config|
  config.mock_with :rr
end

require "test_apps"
