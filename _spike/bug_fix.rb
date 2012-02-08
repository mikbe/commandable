$:.unshift File.expand_path((File.dirname(__FILE__) + '/../lib'))
require 'commandable'

Commandable.color_output = true
Commandable.app_exe = "bug_fix"
Commandable.app_info =
"""
  Testing - Testing Commandable
  Copyleft (c) 2012 Mike Bethany
  http://mikeb.tk
"""

class TestIt
  extend Commandable

  def non_command_method
    puts "test"
  end
  
  command "A directory or file to convert", :default
  def command_method(value="blah")
    puts "value: #{value}"
  end
  
end

Commandable.execute