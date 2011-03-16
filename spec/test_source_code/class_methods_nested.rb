$:.unshift File.expand_path((File.dirname(__FILE__) + '/../../lib'))
require "commandable"

class ClassMethodsNested

  class << self
    extend Commandable
    
    command "hello world"
    def class_foo(int_arg1, number_arg2)
      [int_arg1, number_arg2]
    end

    command "look a function"
    def class_bar(int_arg1, string_arg2="Number 42")
      [int_arg1, string_arg2]
    end
      
    command "run me for stuff to happen"
    def class_qux string_arg1 ="1492", string_arg2 = "I'm a tricky one"
      [string_arg1, string_arg2]
    end
      
    command "I'm another function!"
    def class_baz number_arg1, string_arg2 = "blorp", *array_arg3
      [number_arg1, string_arg2, array_arg3]
    end
      
    command "how would you even send a block on the command line?"
    def class_quuxx decimal_arg1, *array_arg2, &block_arg3
      yield [decimal_arg1, array_arg2]
    end


  end

end