require 'spec_helper'

# These tests MUST run first to be valid

describe Commandable do

  it 'should not raise an error if a non-command method is before a command method' do
    load 'run_first.rb'
    capture_output{Commandable.execute([])}.to_s.should_not match(/Error:/)
  end

  it 'should not raise an error if a non-command class method is before a command method' do
    Commandable.reset_all
    load 'run_first_class.rb'
    capture_output{Commandable.execute([])}.to_s.should_not match(/Error:/)
  end


end