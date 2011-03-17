@@command_options
require "commandable"

class XorClass
  extend Commandable

  command 'a normal method'
  def normal_method
    "normal_method"
  end

  command 'another normal method'
  def normal_method2
    "normal_method2"
  end

  command 'part of the default :xor group', :xor, :default
  def xor_method1
    "xor_method1"
  end
  
  command "also in the default :xor group", :xor
  def xor_method2
    "xor_method2"
  end

  command 'you can also make your own groups', :xor => :xor_group
  def xor_method3
    "xor_method3"
  end
  
  command "use wantever you want as group names", :xor => :xor_group
  def xor_method4
    "xor_method4"
  end

end