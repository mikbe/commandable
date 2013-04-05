require 'bundler'
Bundler::GemHelper.install_tasks

require 'rake'
require 'rdoc/task'
require 'rspec/core/rake_task'

desc "Run all examples"
RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = %w[--color]
  t.verbose = true
end

task :default => [:test, :build]
task :test =>[:spec]

task :clobber do
  rm_rf 'pkg'
  rm_rf 'tmp'
  rm_rf 'coverage'
  rm_rf 'rdoc'
end

Rake::RDocTask.new do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "Commandable #{Commandable::VERSION}"
  rdoc.rdoc_files.exclude('autotest/*')
  rdoc.rdoc_files.exclude('features/*')
  rdoc.rdoc_files.exclude('pkg/*')
  rdoc.rdoc_files.exclude('spec/**/*')
  rdoc.rdoc_files.exclude('vendor/*')
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end