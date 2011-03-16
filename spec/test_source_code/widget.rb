$:.unshift File.expand_path((File.dirname(__FILE__) + '/../../lib'))
require 'commandable'

class Widget
  extend Commandable

  def initialize(name)
    @name = name
  end

  command "create a new widget", :default, :priority=>10
  def name(name)
    puts "You named your widget: #{name}"
  end

  command "destroy an existing widget", :xor
  def disassemble
    "No dissaemble #{name}! #{name} is alive!"
  end
  
  command "spend lots of money to update a widget", :xor
  def upgrade
    "You just gave #{name} a nice new coat of paint!"
  end

end

johnny5 = Widget.new("Johnny 5")
