$:.unshift File.expand_path((File.dirname(__FILE__) + '/../lib'))
$:.unshift File.expand_path((File.dirname(__FILE__) + '/source_code_examples'))
$:.unshift File.expand_path((File.dirname(__FILE__) + '/source_code_for_errors'))
$:.unshift File.expand_path(File.dirname(__FILE__))

require 'term/ansicolor'
require 'rspec'
require 'commandable'

# A note on the specs:
# Since Commandable uses singletons the tests sometimes get confused about their state.
# I'm working on a way to properly clear every thing out of memory before each test but tests
# doesn't pass in autotest try running the test again or run rspec yourself and they'll pass.

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
    puts ""
    puts "*" * 40
    pp value
    puts "&" * 40
    puts ""
  end
end

# Trap STDOUT and STDERR for testing what a method prints to the terminal
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

# Executes a command capturing STDOUT and STDERR as an array representing each line
def execute_output_ary(argv)
  execute_output_s(argv).split(%r{\n})
end

# Executes a command capturing STDOUT and STDERR as one string
def execute_output_s(argv)
  output = capture_output{Commandable.execute(argv)}
  output[:stdout] + output[:stderr]
end
