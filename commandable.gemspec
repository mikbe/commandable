# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "commandable/version"

Gem::Specification.new do |s|
  s.name                    = "commandable"
  s.required_ruby_version   = "~>1.9.2"
  s.version                 = Commandable::VERSION::STRING
  s.platform                = Gem::Platform::RUBY
  s.required_ruby_version   = '>= 1.9.2'
  s.authors                 = ["Mike Bethany"]
  s.email                   = ["mikbe.tk@gmail.com"]
  s.homepage                = "http://mikbe.tk"
  s.summary                 = %q{The easiest way to add command line control to your app.}
  s.description             = <<EOF
The easiest way to add command line control to your app.
Adding command line control to your app is as easy as putting 'command "this command does xyz"' above a method.
Parameter lists and a help command are automatically built for you.
EOF
  s.license = 'MIT'

  s.add_dependency("term-ansicolor-hi", "~>1.0.7")
  
  s.add_development_dependency("rspec", "~>2.5")
  s.add_development_dependency("cucumber", "~>0.10")
  s.add_development_dependency("aruba", "~>0.3")

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {spec,autotest}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
