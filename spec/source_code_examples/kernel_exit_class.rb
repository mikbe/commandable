require "commandable"

class KernelExitClass
  
  extend Commandable
  command 'does some stuff'
  def exit(exit_code = 0)
    Kernel.exit exit_code.to_i
  end 
end
