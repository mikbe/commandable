require 'spec_helper'

describe Commandable do
  
    before(:each) {
    Commandable.reset_all
    Commandable.color_output = true
    Commandable.verbose_parameters = false
    Commandable.app_exe = "fake_app"
    Commandable.app_info =  
    """
      \e[92mFake App!\e[0m - It's not real!
    """
    load "required_default.rb"
  }

  
  context "when there is a required/default command" do

    context "and it has a required parameter" do
      
      context "but nothing is given on the command line" do
        
        it "should say a required parameter is missing" do
          lambda{execute_queue([])}.should raise_error(Commandable::MissingRequiredParameterError)
        end
        
        it "should say a required parameter is missing" do
          execute_output_s([]).should include("default command")
        end
        
      end
      
    end
    
  end
  
end