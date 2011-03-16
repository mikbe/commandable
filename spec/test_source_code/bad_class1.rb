$:.unshift File.expand_path((File.dirname(__FILE__) + '/../../lib'))
require "commandable"

class BadClass1
  extend Commandable
  command 'this should fail because their is no method'
end