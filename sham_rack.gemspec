# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{sham_rack}
  s.version = "1.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Mike Williams"]
  s.date = %q{2009-05-06}
  s.description = %q{ShamRack plumbs Net::HTTP directly into Rack, for quick and easy HTTP testing.}
  s.email = %q{mdub@dogbiscuit.org}
  s.extra_rdoc_files = [
    "README.markdown"
  ]
  s.files = [
    "README.markdown",
    "Rakefile",
    "VERSION.yml",
    "lib/sham_rack.rb",
    "lib/sham_rack/core_ext/net/http.rb",
    "lib/sham_rack/http.rb",
    "lib/sham_rack/registry.rb",
    "spec/sham_rack_spec.rb",
    "spec/spec_helper.rb"
  ]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/mdub/sham_rack}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.2}
  s.summary = %q{Net::HTTP-to-Rack plumbing}
  s.test_files = [
    "spec/sham_rack_spec.rb",
    "spec/spec_helper.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
