require 'spec_helper'

describe Commandable do

  before(:each) { Commandable.reset_all }

  # Mostly de-brittled these tests...

  context "when setting verbose_parameters" do
    
    it "prints short parameters when false" do
      Commandable.verbose_parameters = false
      load 'parameter_class1.rb'
      Commandable.help.to_s.should_not match("1492")
    end
    
    it "prints short parameters when false" do
      Commandable.verbose_parameters = true
      load 'parameter_class1.rb'
      Commandable.help.to_s.should match("1492")
    end
    
  end

  context "when looking at the help command" do

    it "has a help command when no commands have been added" do
      Commandable.commands.first[0].should == :help
    end
  
    it "has still has the help command after Commandable is cleared" do
      load 'parameter_class1.rb'
      Commandable.clear_commands
      Commandable.commands.first[0].should == :help
    end
    
    it "always has the help command as the last command (so it's pretty)" do
      load 'parameter_class1.rb'
      Commandable.help.compact.last.should match(/help/)
    end
  
  end

  context "formating the help message" do
    it "formats a basic help message" do
      load 'parameter_class1.rb'
      Commandable.help.to_s.should match(/Usage:(.*)Command(.*)foo(.*)bar(.*)qux(.*)baz(.*)help/)
     end

    it "adds the application name to the help output if it's given" do
      load 'parameter_class1.rb'
      Commandable.app_name = "mycoolapp"
      Commandable.help.to_s.should match(/Usage: mycoolapp <command>/)
    end

    it "adds appliction information if given" do
      load 'parameter_class1.rb'
      Commandable.app_name = "mycoolapp"
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
      Commandable.help.to_s.should match(/\(default\)/)
    end

  end

  context "when using color_output" do

    before(:each) do 
      load 'private_methods.rb'
      Commandable.app_name = "mycoolapp"
      Commandable.app_info = 
"""  My Cool App - It does stuff and things!
  Copyright (c) 2011 Acme Inc."""
    end

    let(:c) {Term::ANSIColor}
    let(:plain) {["\e[H\e[2J", "  My Cool App - It does stuff and things!\n  Copyright (c) 2011 Acme Inc.", "", "  Usage: mycoolapp [command] [parameters] [[command] [parameters]...]", "", "Command Parameter(s)  Description", "   help               : you're looking at it now"]}
    let(:default_color) {["\e[H\e[2J", "\e[97m\e[1m  My Cool App - It does stuff and things!\n  Copyright (c) 2011 Acme Inc.\e[0m", "", "  \e[90m\e[1mUsage:\e[0m \e[92m\e[1mmycoolapp\e[0m [\e[93m\e[1mcommand\e[0m] [\e[96m\e[1mparameters\e[0m] [[\e[93m\e[1mcommand\e[0m] [\e[96m\e[1mparameters\e[0m]...]", "", "\e[93m\e[1mCommand\e[0m \e[96m\e[1mParameter(s)\e[0m  \e[97m\e[1mDescription\e[0m", "   \e[93mhelp\e[0m \e[96m\e[0m              : \e[97myou're looking at it now\e[0m"]}
    
    it "changes the output if color is enabled" do
      lambda {Commandable.color_output = true}.should change{Commandable.help}
    end

    it "resets text to plain if colors are turned off" do
      Commandable.color_output = true
      lambda {Commandable.color_output = false}.should change{Commandable.help}
    end

    context "when a specific setting's color is changed" do
      
      before(:each) { Commandable.color_output = true } 

      # This seems ripe for meta-zation
      context "when app_info is changed" do
        specify {lambda {Commandable.color_app_info = c.black}.should change{Commandable.help}}
      end

      context "when app_name is changed" do
        specify {lambda {Commandable.color_app_name = c.black}.should change{Commandable.help}}
      end

      context "when color_command is changed" do
        specify {lambda {Commandable.color_command = c.black}.should change{Commandable.help}}
      end

      context "when color_description is changed" do
        specify {lambda {Commandable.color_description = c.black}.should change{Commandable.help}}
      end

      context "when color_parameter is changed" do
        specify {lambda {Commandable.color_parameter = c.black}.should change{Commandable.help}}
      end

      context "when color_usage is changed" do
        specify {lambda {Commandable.color_usage = c.black}.should change{Commandable.help}}
      end

      context "when there is an error" do
        
        specify { lambda {Commandable.color_error_word = c.magenta}.should change{capture_output{Commandable.execute(["fly", "navy"])}}}
        specify { lambda {Commandable.color_error_name = c.intense_red}.should change{capture_output{Commandable.execute(["fly", "navy"])}}}
        specify { lambda {Commandable.color_error_description = c.black + c.bold}.should change{capture_output{Commandable.execute(["fly", "navy"])}}}
        
      end
      
    end

  end

end