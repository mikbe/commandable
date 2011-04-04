require "commandable"

class ClassBad
  extend Commandable
  command 'this should fail because their is no method'
end