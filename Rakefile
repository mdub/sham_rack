require "spec/rake/spectask"

task "default" => "spec"

Spec::Rake::SpecTask.new do |t|
  t.spec_opts = ["--colour", "--format", "progress"]
  t.spec_files = FileList['spec/**/*_spec.rb']
end

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "sham_rack"
    gemspec.summary = "plumbs Net::HTTP into Rack for quick and easy HTTP testing"
    gemspec.email = "mdub@dogbiscuit.org"
    gemspec.homepage = "http://github.com/mdub/sham_rack"
    gemspec.description = "TODO"
    gemspec.authors = ["Mike Williams"]
  end
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end
