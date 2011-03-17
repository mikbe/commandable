@@command_options
require "commandable"

class TestClass
  extend Commandable
  command 'does some stuff'
  def test_method
    "test_method"
  end 
end


puts Commandable.execution_queue([])