$:.unshift File.expand_path((File.dirname(__FILE__) + '/../../lib'))
require "commandable"

class CommandNoCommand
  extend Commandable

  command 'a method with a command'
  def command_method1
    "command_method1"
  end

  # this method should not be in the commands list
  def no_command_method1(flappity)
    "no_command_method1"
  end

  command 'another method with a command'
  def command_method2(some_parameter)
    "command_method2"
  end
  
  # this method shouldn't be in the list either
  def no_command_method2(flippity)
    "no_command_method2"
  end

end