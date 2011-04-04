require "commandable"

class ClassCommandNoCommand
  extend Commandable

  command 'a method with a command'
  def class_command_method1
    "class_command_method1"
  end

  # this method should not be in the commands list
  def class_no_command_method1(flappity)
    "class_no_command_method1: #{flappity}"
  end

  command 'another method with a command'
  def class_command_method2(some_parameter)
    "class_command_method2: #{some_parameter}"
  end
  
  # this method shouldn't be in the list either
  def class_no_command_method2(flippity)
    "class_no_command_method2: #{flippity}"
  end

end