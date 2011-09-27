module Commandable
  module VERSION # :nodoc:
    MAJOR  = 0
    MINOR  = 2
    TINY   = 3
    PRE    = nil

    STRING = [MAJOR, MINOR, TINY, PRE].compact.join('.')

    SUMMARY = "Commandable #{STRING}"
  end
end