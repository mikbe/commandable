require "commandable"

class AttrAccessorMulti
  extend Commandable

  # You can do this just realize the second accessor is ignored
  command 'only runs the first accessor'
  attr_accessor :first_accessor, :second_accessor

  command 'only runs the first writer'
  attr_writer :first_writer, :second_writer
 
end