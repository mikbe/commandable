$:.unshift File.expand_path((File.dirname(__FILE__) + '/../../lib'))
require "commandable"

# This is just a not so clever way of getting at the instance methods of Commandable
# Accessing the private methods of a class/module is a bad idea but I really need to
# test them and making a helper module just to test them is also against best practices
# so...
class PrivateMethods
  extend Commandable
end