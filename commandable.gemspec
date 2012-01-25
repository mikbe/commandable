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
The easiest way to add command line control to your Ruby app. You can add a single line above an existing method and that method will be available from the command line.
Best of all the help/usage instructions are automatically generated using the method definition itself. When you change your methods the help instructions change automajically!
EOF

  s.license = 'MIT'

  s.add_dependency("term-ansicolor", "~>1.0.7")
  
  s.add_development_dependency("rspec", "~>2.5")

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {spec,autotest}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
