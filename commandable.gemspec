# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "commandable/version"

Gem::Specification.new do |s|
  s.name                    = "commandable"
  s.required_ruby_version   = "~>1.9.2"
  s.version                 = Commandable::VERSION
  s.platform                = Gem::Platform::RUBY
  s.authors                 = ["Mike Bethany"]
  s.email                   = ["mikbe.tk@gmail.com"]
  s.homepage                = "http://mikbe.tk"
  s.summary                 = %q{The easiest way to add command line control to your app.}
  s.description             = %q{The easiest way to add command line control to your app.\nAdding command line control to your app is as easy as putting 'command "this command does xyz"' above a method.\nParameter lists and a help command are automatically built for you.}

  s.add_dependency("term-ansicolor-hi", "~>1.0.7")
  
  s.add_development_dependency("rspec", "~>2.5")
  s.add_development_dependency("cucumber")

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {spec,autotest}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
