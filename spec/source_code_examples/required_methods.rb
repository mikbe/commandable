@@command_options
require "commandable"

class RequiredMethods
  
  extend Commandable

  command :required, 'does some stuff'
  def required_method(gimmie)
    gimmie
  end
  
  command "another one"
  def non_required_method(meh)
    meh
  end

end