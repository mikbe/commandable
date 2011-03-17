@@command_options
require "commandable"

class ParameterFree
  extend Commandable

  command 'this method has no params'
  def no_parms1
    "no_parms1"
  end

  command 'none here either'
  def no_parms2
    "no_parms2"
  end

  command 'nope, still none'
  def no_parms3
    "no_parms3"
  end

end