require "commandable"

class DefaultMethodNoParams
  extend Commandable
  
  command 'does some stuff', :default
  def default_no_params
    "default method called, has no params"
  end 
  
  command 'does other stuff'
  def not_a_default_method(name="Cleveland", age)
    ["not a default method: #{name}", age]
  end 

end