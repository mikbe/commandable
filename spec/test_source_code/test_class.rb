$:.unshift File.expand_path((File.dirname(__FILE__) + '/../../lib'))
require "commandable"

class TestClass
  extend Commandable
  command 'does some stuff'
  def test_method
  end 
end
