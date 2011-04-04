require "commandable"

class InstanceMethods2
  extend Commandable
  
  command "save a value", :priority=>2
  def set_value2(value)
    @value = value
  end 
  
  command "retreive a value"
  def get_value2
    @value
  end
 
end