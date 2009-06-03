require "rubygems"
require "rake"

require "spec/rake/spectask"

task "default" => "spec"

Spec::Rake::SpecTask.new do |t|
  t.spec_opts = ["--colour", "--format", "progress"]
  t.spec_files = FileList['spec/**/*_spec.rb']
end

require "jeweler"

Jeweler::Tasks.new do |g|
  g.name = "sham_rack"
  g.summary = "Net::HTTP-to-Rack plumbing"
  g.email = "mdub@dogbiscuit.org"
  g.homepage = "http://github.com/mdub/sham_rack"
  g.description = "ShamRack plumbs Net::HTTP directly into Rack, for quick and easy HTTP testing."
  g.authors = ["Mike Williams"]
  g.rubyforge_project = "shamrack"
end

Jeweler::RubyforgeTasks.new

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  if File.exist?('VERSION.yml')
    config = YAML.load(File.read('VERSION.yml'))
    version = "#{config[:major]}.#{config[:minor]}.#{config[:patch]}"
  else
    version = ""
  end

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "ShamRack #{version}"
  rdoc.main = "ShamRack"
  rdoc.rdoc_files.include('lib/**/*.rb')
end
