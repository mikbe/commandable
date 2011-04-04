require "commandable"

class ClassMethods
  
  extend Commandable

  command 'does some stuff'
  def self.class_method(string_arg1)
    string_arg1
  end
  
  command "another one"
  class << self
    def class_method2(integer_arg1)
      integer_arg1
    end
  end

end