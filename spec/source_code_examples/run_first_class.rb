require "commandable"

Commandable.color_output = true
Commandable.app_exe = "bug_fix"
Commandable.app_info =
"""
  Testing - Testing Commandable
  Copyleft (c) 2012 Mike Bethany
  http://mikeb.tk
"""

class RunFirstClass
  extend Commandable

  def self.non_command_method
    puts "class non_command_method"
  end
  
  command "default method", :default
  def command_method
    puts "#command_method"
  end
  
end