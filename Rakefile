require "rubygems"
require "rake"

require File.dirname(__FILE__) + "/lib/sham_rack/version.rb"

require "spec/rake/spectask"

task "default" => "spec"

Spec::Rake::SpecTask.new do |t|
  t.spec_opts = ["--colour", "--format", "progress"]
  t.spec_files = FileList['spec/**/*_spec.rb']
end

require 'rake/rdoctask'

Rake::RDocTask.new do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "ShamRack #{ShamRack::VERSION}"
  rdoc.main = "ShamRack"
  rdoc.rdoc_files.include('lib/**/*.rb')
end

def after_requiring(lib, options = {})
  begin
    require(lib)
  rescue LoadError
    gem_name = options[:gem] || lib
    $stderr.puts "WARNING: can't load #{lib}.  Install it with: sudo gem install #{gem_name}"
    return false
  end
  yield
end

after_requiring "jeweler" do

  Jeweler::Tasks.new do |g|
    g.name = "sham_rack"
    g.version = ShamRack::VERSION
    g.summary = "Net::HTTP-to-Rack plumbing"
    g.email = "mdub@dogbiscuit.org"
    g.homepage = "http://github.com/mdub/sham_rack"
    g.description = "ShamRack plumbs Net::HTTP directly into Rack, for quick and easy HTTP testing."
    g.authors = ["Mike Williams"]
    g.rubyforge_project = "shamrack"
  end

  Jeweler::GemcutterTasks.new
  # Jeweler::RubyforgeTasks.new

end
