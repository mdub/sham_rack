$: << File.expand_path("../lib", __FILE__)
require "sham_rack/version"

Gem::Specification.new do |gem|

  gem.name = "sham_rack"
  gem.summary = "Net::HTTP-to-Rack plumbing"
  gem.description = "ShamRack plumbs Net::HTTP directly into Rack, for quick and easy HTTP testing."

  gem.homepage = "http://github.com/mdub/sham_rack"
  gem.authors = ["Mike Williams"]
  gem.email = "mdub@dogbiscuit.org"

  gem.rubyforge_project = "shamrack"

  gem.version = ShamRack::VERSION.dup
  gem.platform = Gem::Platform::RUBY

  gem.add_dependency "rack", ">= 1.4.1"

  gem.require_path = "lib"
  gem.files = Dir["lib/**/*", "README.markdown", "CHANGES.markdown"]
  gem.test_files = Dir["spec/**/*", "Rakefile", "benchmark/**/*"]

end
