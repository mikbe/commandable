require 'spec_helper'

describe Commandable do

  before(:each) { Commandable.reset_all }

  # Mostly de-brittled these tests...

  context "when setting verbose_parameters" do
    
    it "prints short parameters when false" do
      Commandable.verbose_parameters = false
      load 'parameter_class.rb'
      Commandable.help.to_s.should_not match("1492")
    end
    
    it "prints short parameters when false" do
      Commandable.verbose_parameters = true
      load 'parameter_class.rb'
      Commandable.help.to_s.should match("1492")
    end
    
  end

  context "when generating the help command" do

    it "has a help command when no commands have been added" do
      Commandable.commands.first[0].should == :help
    end
  
    it "still has the help command after Commandable is cleared" do
      load 'parameter_class.rb'
      Commandable.clear_commands
      Commandable.commands.first[0].should == :help
    end
    
    it "always has the help command as the last command (so it's pretty)" do
      load 'parameter_class.rb'
      Commandable.help.compact.last.should match(/help/)
    end
  
  end

  context "when formating the help message" do
    
    it "formats a basic help message with commands sorted alphabetically (help last)" do
      load 'parameter_class.rb'
      Commandable.help.to_s.should match(/Usage:(.*)Command(.*)bar(.*)baz(.*)foo(.*)qux(.*)help/)
    end

    it "adds the application name to the help output if it's given" do
      Commandable.color_output = false
      load 'parameter_class.rb'
      Commandable.app_exe = "mycoolapp"
      Commandable.help.to_s.should match(/Usage: mycoolapp <command>/)
    end

    it "adds appliction information if given" do
      load 'parameter_class.rb'
      Commandable.app_exe = "mycoolapp"
      app_info = 
"""
  My Cool App - It does stuff and things!
  Copyright (c) 2011 Acme Inc.
"""
      Commandable.app_info = app_info
      Commandable.help.inspect.should match(/My Cool App - It does stuff and things(.*)Copyright \(c\) 2011 Acme Inc/)
    end

    it "adds (default) to the end of the default command description when printing" do
      load 'default_method.rb'
      Commandable.color_output = true
      Commandable.help.join.should match(/\(default\)/)
      Commandable.color_output = false
      Commandable.help.join.should match(/\(default\)/)
    end

    context "and there are no parameters" do
      
      before(:each){load 'parameter_free.rb' }
      
      it "hides the Parameters header" do
        execute_output_s([]).should_not match(/Command Parameters/)
      end

      it "hides the doesn't show [parameters] in the usage instructions" do
        Commandable.app_exe = "fakeapp"
        execute_output_s([]).should_not match(/\[parameters\]/)
      end

    end
    
    context "and there is a new line in a description" do
      
      it "indents the new line to match the preceding line" do
        load("multi_line_description.rb")
        execute_output_s(["blah"]).should match(/                                  so you can have really long descriptions\n                                  And another line/)
      end
      
      it "indents the new line to match the preceding line" do
        load("multi_line_description_no_params.rb")
        execute_output_s(["blah"]).should match(/                                 so you can have really long descriptions\n                                 And another line/)
      end
      
    end
    
  end

end
