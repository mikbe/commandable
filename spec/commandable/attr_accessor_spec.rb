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
  }

  
  context "when command is used on an attr_accessor" do
    
    context 'when there is a single accessor per line' do

      before(:each) { load 'attr_accessor.rb' }
      
      context "when testing syntax" do
        
        it "should work with an attr_accessor" do
          lambda{execute_queue(["some_accesor", "a value"])}.should_not raise_error
        end
      
        it "should work with an attr_writer" do
          lambda{execute_queue(["some_writer", "used the writer"])}.should_not raise_error
        end

        it "should work with an attr_writer and an attr_accessor" do
          lambda{execute_queue(["some_accesor", "a value", "some_writer", "used the writer"])}.should_not raise_error
        end
      
        it "should raise an error is a value isn't given" do
          lambda{execute_queue(["some_accesor"])}.should raise_error(Commandable::MissingRequiredParameterError)
        end
      
        it "should raise an error is a value isn't given" do
          lambda{execute_queue(["some_writer"])}.should raise_error(Commandable::MissingRequiredParameterError)
        end
      
        it "should raise an error is a value isn't given" do
          lambda{execute_queue(["some_accesor", "some_writer", "used the writer"])}.should raise_error(Commandable::MissingRequiredParameterError)
        end
      
        it "should raise an error is a value isn't given" do
          lambda{execute_queue(["some_accesor", "a value", "some_writer"])}.should raise_error(Commandable::MissingRequiredParameterError)
        end
      end
      
      it {execute_output_s(["some_accesor", "a value"]).should include("a value")}
      it {execute_output_s(["some_writer", "blah blah blah"]).should include("blah blah blah")}
      
    end
    
    context 'when there is more than one accessor on the same line' do

      before(:each) { load 'attr_accessor_multi.rb' }
      
      context "when testing syntax" do
        it "should use the first accessor" do
          lambda{execute_queue(["first_accessor", "a value"])}.should_not raise_error
        end
      
        it "should ignore the second accessor" do
          lambda{execute_queue(["second_accessor", "blipidy"])}.should raise_error
        end

        it "should use the first writer" do
          lambda{execute_queue(["first_writer", "a value"])}.should_not raise_error
        end
      
        it "should ignore the second writer" do
          lambda{execute_queue(["second_writer", "blipidy"])}.should raise_error
        end
      end

      it {execute_output_s(["first_accessor", "my very own accessor"]).should include("my very own accessor")}
      it {execute_output_s(["first_writer", "Look ma! A writer!"]).should include("Look ma! A writer!")}
      
    end
    
  end
  
end