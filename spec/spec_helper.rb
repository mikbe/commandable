$:.unshift File.expand_path((File.dirname(__FILE__) + '/../lib'))
$:.unshift File.expand_path((File.dirname(__FILE__) + '/test_source_code'))
$:.unshift File.expand_path(File.dirname(__FILE__))

require 'term/ansicolor'
require 'rspec'
require 'commandable'

# Debug print
module Kernel
  def dp(value)
    puts ""
    puts "*" * 40
    puts "value: #{value}"
    puts "&" * 40
    puts ""
  end
  def dpi(value)
    dp(value.inspect)
  end
end

# Trap STDOUT and STDERR for testing puts commands
def capture_output
  begin
    require 'stringio'
    $o_stdout, $o_stderr = $stdout, $stderr
    $stdout, $stderr = StringIO.new, StringIO.new
    yield
    {:stdout => $stdout.string, :stderr => $stderr.string}
  ensure
    $stdout, $stderr = $o_stdout, $o_stderr
  end
end

# Captures printed output and returns an array of lines
def execute_output_ary(argv)
  execute_output_s(argv).split(%r{\n})
end

def execute_output_s(argv)
  capture_output{Commandable.execute(argv)}[:stdout]
end