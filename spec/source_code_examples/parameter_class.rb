@@command_options
require "commandable"

class ParameterClass
  extend Commandable

  command "hello world"
  def foo(int_arg1, number_arg2)
    [int_arg1, number_arg2]
  end

  command "look a function"
  def bar(int_arg1, string_arg2="Number 42")
    [int_arg1, string_arg2]
  end
  
  command "run me for stuff to happen"
  def qux string_arg1 ="1492", string_arg2 = "I'm a tricky one"
    [string_arg1, string_arg2]
  end
  
  command "I'm another function!"
  def baz number_arg1, string_arg2 = "blorp", *array_arg3
    [number_arg1, string_arg2, array_arg3]
  end

  command "a method with a required parameter"
  def zaz(required_param, another_required)
    [required_param, another_required]
  end

end
