$:.unshift File.expand_path((File.dirname(__FILE__) + '/../../lib'))
require "commandable"

class TestClass1
  extend Commandable
  command 'does some stuff'
  def method1
  end 
end
