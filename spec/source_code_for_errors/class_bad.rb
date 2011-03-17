$:.unshift File.expand_path((File.dirname(__FILE__) + '/../../lib'))
require "commandable"

class ClassBad
  extend Commandable
  command 'this should fail because their is no method'
end