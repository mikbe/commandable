require 'spec_helper'

describe Commandable do

  before(:each) do 
    Commandable.reset_all
    load 'private_methods_bad.rb'
    Commandable.app_exe = "mycoolapp"
    Commandable.app_info = 
"""  My Cool App - It does stuff and things!
  Copyright (c) 2011 Acme Inc."""
  end

  let(:c) {Term::ANSIColor}

  context "when screen clearing" do

    it "should clear the screen if screen clearing is on" do
      Commandable.clear_screen = true
      clear_screen_code = Regexp.escape("#{Commandable.clear_screen_code}")
      Commandable.help.join.should match(clear_screen_code)
    end

    it "should not clear the screen if screen clearing is off" do
      Commandable.clear_screen = true
      clear_screen_code = Regexp.escape("#{Commandable.clear_screen_code}")
      Commandable.clear_screen = false
      Commandable.help.join.should_not match(clear_screen_code)
    end

    it "should change how the screen is cleared" do
      Commandable.clear_screen = true
      clear_code = "FlabbityJibbity"
      Commandable.clear_screen_code = clear_code
      Commandable.help.join.should match(clear_code)
    end

    it "should not be disabled when color output is disabled" do
      Commandable.clear_screen = true
      clear_screen_code = Regexp.escape("#{Commandable.clear_screen_code}")
      Commandable.color_output = false
      Commandable.help.join.should match(clear_screen_code)
    end

  end

  context "when a setting color is changed" do
    
    before(:each) { Commandable.color_output = true } 
  
    it "should include colors if colored output is enabled" do
      Commandable.color_output = true
      Commandable.help.join.should match(Regexp.escape(Commandable.color_app_info))
    end

    it "should not include colors if colored output is disabled" do
      Commandable.color_output = false
      Commandable.help.join.should_not match(Regexp.escape(Commandable.color_app_info))
    end

    # This seems ripe for meta-zation
    context "and app_info is changed" do
      specify {lambda {Commandable.color_app_info = c.black}.should change{Commandable.help}}
    end

    context "and app_exe is changed" do
      specify {lambda {Commandable.color_app_exe = c.black}.should change{Commandable.help}}
    end

    context "and color_command is changed" do
      specify {lambda {Commandable.color_command = c.black}.should change{Commandable.help}}
    end

    context "and color_description is changed" do
      specify {lambda {Commandable.color_description = c.black}.should change{Commandable.help}}
    end

    context "and color_parameter is changed" do
      specify {lambda {Commandable.color_parameter = c.black}.should change{Commandable.help}}
    end

    context "and color_usage is changed" do
      specify {lambda {Commandable.color_usage = c.black}.should change{Commandable.help}}
    end

    context "and there is an error" do
      
      specify { lambda {Commandable.color_error_word = c.magenta}.should change{capture_output{Commandable.execute(["fly", "navy"])}}}
      specify { lambda {Commandable.color_error_name = c.intense_red}.should change{capture_output{Commandable.execute(["fly", "navy"])}}}
      specify { lambda {Commandable.color_error_description = c.black + c.bold}.should change{capture_output{Commandable.execute(["fly", "navy"])}}}
      
    end
    
  end

end