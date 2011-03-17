$:.unshift File.expand_path((File.dirname(__FILE__) + '/../../lib'))
require "commandable"

class MultiLineDescriptionNoParams
  extend Commandable

  command "this description will be on multiple lines\nso you can have really long descriptions\nAnd another line\nAnd another"
  def multiline_function_no_params1
    "multiline_function_no_params1"
  end

  command "Line one is short line two blah, blah! Oh, and blah!"
  def multiline_function_no_params2
    "multiline_function_no_params2"
  end

end
