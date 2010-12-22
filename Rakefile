require "rubygems"
require "rake"

require "spec/rake/spectask"

task "default" => "spec"

Spec::Rake::SpecTask.new do |t|
  t.spec_opts = ["--colour", "--format", "nested"]
  t.spec_files = FileList['spec/**/*_spec.rb']
end

require 'bundler'

Bundler::GemHelper.install_tasks
