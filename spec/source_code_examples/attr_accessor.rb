require "commandable"

class AttrAccessor
  extend Commandable

  command 'uses an attr_accessor'
  attr_accessor :some_accesor

  command 'uses an attr_writer'
  attr_writer :some_writer
 
 
end