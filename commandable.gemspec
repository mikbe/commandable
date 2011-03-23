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
  s.summary                 = %q{The easiest way to add command line control to your Ruby apps.}
  s.description             = <<EOF
The easiest way to add command line control to your Ruby app.

Stop wasting time writing WET (Write Everything Twice) command line interpreters, or repeatedly writing code for existing ones like optparser, then writing help/usage methods that you constantly have to update as your code changes. Now you can add a single line above an existing method and that method will be available from the command line.

Best of all the help/usage instructions are automatically generated using the method itself! When you change your methods the help instructions change automajically! There's no extra effort needed on your part.

The whole process can take as little as four lines of code:  

* You put a `command "I do something!"` line above your method.
* Add a `require 'commandable'` line somewhere (I'd put it in my bin).
* Then an `extend Commandable` inside your class.
* And finally a call to `Commandable.execute(ARGV)` in your bin file. 

Don't think of Commandable as a way to add command line switches to your app but as a way to allow your app to be driven directly from the command line. No more confusing switches that mean one thing in one program and something completely different in another. (Can you believe some apps actually use `-v` for something other than "version" and `-h` for something other than "help?" Madness I say! Madness!)

You can now "use your words" to let people interact with your apps in a natural way.
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
