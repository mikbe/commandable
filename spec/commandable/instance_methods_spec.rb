require 'spec_helper'

describe Commandable do
  
  context "when calling instance methods" do
    
    before(:each) do
      @first_value = "the first value saved"
      @second_value = "the second saved value"
    end
    
    it "saves instance variables between method calls" do
      load 'instance_methods.rb'
      values = execute_queue(["set_value", @first_value, "get_value"])
      values[1].should == @first_value
    end

    context 'when multiple classes are involved' do
    
      it "saves instance variables between method calls" do
        load 'instance_methods.rb'
        load 'instance_methods2.rb'
        values2 = execute_queue(["set_value2", @second_value, "get_value2"])
        values2[1].should == values2[0]
        execute_queue(["get_value"])[0].should == @first_value
      end
    
    end
    
    context "when running the execution queue manually" do
      
      it "should give a programmer access to any instances created" do
        Commandable.reset_all
        load 'instance_methods.rb'
        load 'instance_methods2.rb'
        execute_queue(["set_value", @first_value, "get_value"])
        execute_queue(["set_value2", @second_value, "get_value2"])
        Commandable.class_cache.keys.should include("InstanceMethods", "InstanceMethods2")
      end
      
    end
     
  end
  
end