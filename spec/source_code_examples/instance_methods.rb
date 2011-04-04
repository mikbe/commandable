require "commandable"

class InstanceMethods
  extend Commandable
  
  command "save a value", :priority=>2
  def set_value(value)
    @value = value
  end 
  
  command "retreive a value"
  def get_value
    @value
  end
 
end