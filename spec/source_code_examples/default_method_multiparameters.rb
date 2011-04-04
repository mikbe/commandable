require "commandable"

class DefaultMethodsMultiParameters
  extend Commandable
  
  command 'the default method', :default
  def default_method_multi(name, optional="optional")
    "multi default method called with: #{name}, #{optional}"
  end 
  
  command 'does other stuff'
  def not_a_default_method_multi(name="Cleveland", age)
    ["multi not a default method, called with: #{name}", age]
  end 

end