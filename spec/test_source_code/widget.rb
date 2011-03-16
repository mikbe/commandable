$:.unshift File.expand_path((File.dirname(__FILE__) + '/../../lib'))
require 'commandable'

class Widget
  extend Commandable

  # You shouldn't try to use initialize in a class you want to make Commandable.
  # Commandable creates a new class automatically for instance methods so if you
  # have any parameters for your initialize it will raise an error. In fact I can't
  # even trap initialize properly because the Commandable module isn't initialized
  # until after your class has been initialized.
  # 
  # Think of the classes you let Commandable control as entry points to your app.
  # Don't try to have Commandable do a lot of class creation and manipulation of
  # your application, just have the methods you call do all that.
  def initialize
    puts "Widget Initialized!"
  end

  command "create a new widget", :default, :priority=>10
  # You can however override the new command because when your
  # method gets called the class will already be initialized. 
  def self.new(name)
    puts "name: #{name}"
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
