$:.unshift File.expand_path((File.dirname(__FILE__) + '/../../lib'))
require "commandable"

class DefaultMethodsBad
  extend Commandable
  
  command 'does some stuff', :default
  def default_method
    "default_method"
  end 
  
  command 'does some other stuff', :default
  def default_method2
    "default_method2"
  end 

end