$:.unshift File.expand_path((File.dirname(__FILE__) + '/../../lib'))
require "commandable"

class DefaultMethodNoParams
  extend Commandable
  
  command 'does some stuff', :default
  def default_method_no
    "default method called, has no params"
  end 
  
  command 'does other stuff'
  def not_a_default_method(name="Cleveland", age)
    ["not a default method: #{name}", age]
  end 

end