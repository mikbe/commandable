require "commandable"

class RequiredDefault
  extend Commandable
  
  command "the default action", :default, :required
  def required_default(required_value)
    value
  end 
 
end