require 'spec_helper'

describe Commandable do

  before(:each) {
    Commandable.reset_all
    Commandable.color_output = true
    Commandable.verbose_parameters = false
    Commandable.app_name = "commandable"
    Commandable.app_info =  
    """
      \e[92mCommandable\e[0m - The easiest way to add command line control to your app.
      Copyrighted free software - Copyright (c) 2011 Mike Bethany.
      Version: #{Commandable::VERSION::STRING}
    """

    # App controller has to be loaded after commandable settings
    # or it won't be able to use the settings
    load 'commandable/app_controller.rb'
  }
  
  context "when running the widget command" do
    
    context "when git isn't installed" do
      
      it "should inform them they need Git" do
        Commandable::AppController.stub(:git_installed?){false}
        execute_output_s(["widget"]).should match(/Git must be installed/)
      end
    
    end
    context "when git is installed" do

      it "should download Widget from github" do
        Commandable::AppController.stub(:download_widget){0}
        execute_queue(["widget"]).should == [0]
      end
    
    end

    
  end

end