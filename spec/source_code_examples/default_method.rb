require "commandable"

class DefaultMethods
  extend Commandable
  
  command 'the default method', :default
  def default_method(name)
    "default method called with: #{name}"
  end 
  
  command 'does other stuff'
  def not_a_default_method(name="Cleveland", age)
    "not a default method, called with: #{name}, #{age}"
  end 

end