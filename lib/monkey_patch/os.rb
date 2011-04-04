require 'sys/uname'
include Sys

module Kernel
  def is_windows?
    Uname.sysname.downcase.include?('windows')
  end
end