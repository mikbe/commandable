require 'spec_helper'

describe Commandable do

  before(:each) {
    Commandable.reset_all
    Commandable.app_exe = "mycoolapp"
    Commandable.app_info = 
"""
  My Cool App - It does stuff and things!
  Copyright (c) 2011 Acme Inc.
"""

    load 'kernel_exit_class.rb'
  }

  it "should not trap kernel exits" do
    lambda{execute_queue(['exit'])}.should raise_error(SystemExit)
  end
  
  it "should forward kernel exit status codes" do
    lambda{execute_queue(['exit', '40'])}.should raise_error(SystemExit) { |error|
      error.status.should == 40
    }
  end

end