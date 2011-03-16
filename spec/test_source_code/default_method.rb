$:.unshift File.expand_path((File.dirname(__FILE__) + '/../../lib'))
require "commandable"

class DefaultMethods
  extend Commandable
  
  command 'the default method', :default
  def default_method(name)
    "default method called: #{name}"
  end 
  
  command 'does other stuff'
  def not_a_default_method(name="Cleveland", age)
    ["not a default method: #{name}", age]
  end 

end