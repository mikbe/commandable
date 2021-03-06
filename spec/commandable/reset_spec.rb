require 'spec_helper'

describe Commandable do

  before(:each) do
    Commandable.reset_all
    load 'parameter_class.rb'
    Commandable.app_exe = "mycoolapp"
    Commandable.app_info = 
"""  My Cool App - It does stuff and things!
  Copyright (c) 2011 Acme Inc."""
  end
  
  context "when reseting all values" do
     
    specify {lambda{Commandable.reset_all}.should change{Commandable.app_exe}.from("mycoolapp").to(nil)}
    specify {lambda{Commandable.reset_all}.should change{Commandable.app_info}.
      from(%{  My Cool App - It does stuff and things!\n  Copyright (c) 2011 Acme Inc.}).
      to(nil)
    }
    specify {lambda{Commandable.reset_all}.should change{Commandable.commands.length}.from(6).to(1)}
    


  end
end