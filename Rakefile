require "rubygems"
require "rake"

task "default" => "spec"

require "rspec/core/rake_task"

RSpec::Core::RakeTask.new do |t|
  t.rspec_opts = ["--format", "nested"]
end

require 'bundler'

Bundler::GemHelper.install_tasks
