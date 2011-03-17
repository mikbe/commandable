$:.unshift File.expand_path((File.dirname(__FILE__) + '/../../lib'))
require "commandable"

class NoDescription
  extend Commandable
  command
  def method_with_no_description
    "called method_with_no_description"
  end
end