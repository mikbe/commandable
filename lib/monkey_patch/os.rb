require 'sys/uname'
include Sys

class Kernel
  class << self
    def is_windows?
      Uname.sysname.downcase.include?('windows')
    end
  end
end