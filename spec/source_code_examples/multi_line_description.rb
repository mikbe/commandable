@@command_options
require "commandable"

class MultiLineDescription
  extend Commandable

  command "this description will be on multiple lines\nso you can have really long descriptions\nAnd another line\nAnd another"
  def multiline_function1
    "multiline_function1"
  end

  command "Line one is short line two blah, blah! Oh, and blah!"
  def multiline_function2(foo)
    "multiline_function2: #{foo}"
  end

end
