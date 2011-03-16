require 'bundler'
Bundler::GemHelper.install_tasks

require "rake"
require "rake/rdoctask"
require "rspec/core/rake_task"

desc "Run all examples"
RSpec::Core::RakeTask.new(:spec) do |t|
  #t.rspec_path = 'spec'
  t.rspec_opts = %w[--color]
  t.verbose = false
end

namespace :rcov do
  task :cleanup do
    rm_rf 'coverage.data'
  end

  RSpec::Core::RakeTask.new :spec do |t|
    t.rcov = true
    t.rcov_opts =  %[-Ilib -Ispec --exclude "gems/*,features"]
    t.rcov_opts << %[--no-html --aggregate coverage.data]
  end

end

task :default => [:spec, :build]

task :clobber do
  rm_rf 'pkg'
  rm_rf 'tmp'
  rm_rf 'coverage'
end

Rake::RDocTask.new do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "commandable #{Commandable::VERSION}"
  rdoc.rdoc_files.exclude('autotest/*')
  rdoc.rdoc_files.exclude('spec/**/*')
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end