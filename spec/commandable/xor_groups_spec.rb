require 'spec_helper'

describe Commandable do

  before(:each) do
    Commandable.reset_all
    load 'xor_class.rb'
  end
  
  context "when exclusive methods are specified" do

    specify {Commandable.commands[:xor_method1][:xor].should == :xor}
    specify {Commandable.commands[:normal_method][:xor].should be_nil}
    specify {Commandable.commands[:xor_method3][:xor].should == :xor_group}
    
    context "when more than one members of an exclusive group is used" do
      
      specify{lambda{Commandable.execution_queue(["xor_method1", "xor_method2"])}.should raise_error(Commandable::ExclusiveMethodClashError)}
      specify{lambda{Commandable.execution_queue(["xor_method3", "xor_method4"])}.should raise_error(Commandable::ExclusiveMethodClashError)}
      specify{lambda{Commandable.execution_queue(["xor_method1", "xor_method3"])}.should_not raise_error}
      specify{lambda{Commandable.execution_queue(["normal_method", "xor_method3"])}.should_not raise_error}
      specify{lambda{Commandable.execution_queue(["normal_method", "normal_method2"])}.should_not raise_error}
      
    end
    
    context "when printing help" do
    
      it "puts the xor group in the description" do
        
        puts Commandable.help
        
        true.should be_false
        
      end
    
    end
    
    
  end
  
end