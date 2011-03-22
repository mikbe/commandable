module Commandable
  module VERSION # :nodoc:
    MAJOR  = 0
    MINOR  = 2
    TINY   = 0
    PRE    = "rc1"

    STRING = [MAJOR, MINOR, TINY, PRE].compact.join('.')

    SUMMARY = "Commandable #{STRING}"
  end
end