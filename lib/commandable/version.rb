# :nodoc:
module Commandable
  module VERSION
    MAJOR  = 0
    MINOR  = 3
    TINY   = 2
    PRE    = nil

    STRING = [MAJOR, MINOR, TINY, PRE].compact.join('.')

    SUMMARY = "Commandable #{STRING}"
  end
end