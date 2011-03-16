require 'spec_helper'

describe Commandable do

  before(:each) {
    Commandable.reset_all
    Commandable.app_name = "mycoolapp"
    Commandable.app_info = 
"""
  My Cool App - It does stuff and things!
  Copyright (c) 2011 Acme Inc.
"""

    load 'parameter_class.rb'
  }

  context "when parsing arguments" do
  
    context "when there is an error in the command line" do
    
      context "when running procs from the execution queue" do
        it "raises an error if there is an invalid command given" do
          lambda{Commandable.execution_queue(["fly", "navy"])}.should raise_error(Commandable::UnknownCommandError)
        end
      end
    
      context "when running commands automatically via execute" do
        
        context "when an unknown command is sent" do
          it "traps errors" do
            capture_output{lambda{Commandable.execute(["fly", "navy"])}.should_not raise_error}
          end
          it "prints the error" do
            capture_output{Commandable.execute(["fly", "navy"])}.to_s.should 
              match(/Error: Unknown Command(.*)There is no \\\"fly\\\" command/)
          end
          it "prints usage/help instructions" do
            capture_output{Commandable.execute(["fly", "navy"])}.to_s.should match(/Usage:/)
          end
        end

        context "when an unknown command is sent" do
          
          before(:each) { load 'required_methods.rb' }
          it "traps errors" do
            capture_output{lambda{Commandable.execute(["non_required_method", "blorp"])}.should_not raise_error}
          end
          it "prints the error" do
            capture_output{Commandable.execute(["non_required_method", "blorp"])}.to_s.should
             match(/Error: Missing Required Command(.*)The required command \\\"required_method\\\" is missing/)
          end
          it "prints usage/help instructions" do
            capture_output{Commandable.execute(["non_required_method", "blorp"])}.to_s.should match(/Usage:/)
          end
        end
        
      end
    
    end

    context "when the command line is valid" do
      
      it "does not raise an error" do
        capture_output{Commandable.execute(["foo", "1", "2"])}.to_s.should_not match(/Error:/)
      end

      context "when automatically executing commands" do
        specify {execute_output_ary(["foo", "1", "2.4"]).should == ["1", "2.4"]}
        specify {execute_output_ary(["bar", "234"]).should == ["234", "Number 42"]}
        specify {execute_output_ary(["bar", "39", "potato"]).should == ["39", "potato"]}
        specify {execute_output_ary(["qux"]).should == ["1492", "I'm a tricky one"]}
        specify {execute_output_ary(["qux", "991"]).should == ["991", "I'm a tricky one"]}
        specify {execute_output_ary(["qux", "1821", "Look I've got %special\"characters\" in me"]).should == 
          ["1821", "Look I've got %special\"characters\" in me"]}
      end

      context "when using the execution_queue command" do

        context "when only one command is given" do
          
          it "only has one command in the array" do
            command_array = Commandable.execution_queue(["foo", "1", "2.4"])
            command_array.length.should == 1
          end
          
          it "properly parses parameters" do
            command_array = Commandable.execution_queue(["foo", "1", "2.4"])
            command_array.first[:parameters].should == ["1", "2.4"]
          end
          
        end
        
        context "when more than one command is given" do
          
          it "has the correct number of commands in the array" do
            command_array = Commandable.execution_queue(["foo", "1", "2.4", "bar", "71"])
            command_array.length.should == 2
          end

          it "properly parses parameters" do
            command_array = Commandable.execution_queue(["foo", "1", "2.4", "bar", "71"])
            command_array.each do |command|
              command[:parameters].should == ["71"] if command[:method] == :bar
              command[:parameters].should == ["1", "2.4"] if command[:method] == :foo
            end
          end
          
        end
        
      end
      
      context "when there are greedy parameters" do
        # number_arg1, string_arg2 = "blorp", *array_arg3
        specify {execute_output_ary(["baz", "9"]).should == ["9", "blorp"]}
        specify {execute_output_ary(["baz", "81", "Fish"]).should == ["81", "Fish"]}
        specify {execute_output_ary(["baz", "3278", "Bubba", "Blip"]).should == ["3278", "Bubba", "Blip"]}
        specify {execute_output_ary(["baz", "0.0234", "Yellow", "Mellow", "Fellow", "bellow", "elbow"]).should == 
          ["0.0234", "Yellow", "Mellow", "Fellow", "bellow", "elbow"]
        }

        context "and it has multiple commands" do
          
          specify {execute_output_ary(["baz", "0.0234", "Yellow", "Mellow", "elbow", "qux"]).should ==
              ["1492", "I'm a tricky one",
              "0.0234", "Yellow", "Mellow", "elbow"]
          }
          
          specify {execute_output_ary(["baz", "0.0234", "Yellow", "Mellow", "elbow", "foo", "17", "432", "qux"]).should == 
              ["1492", "I'm a tricky one",
              "17", "432", 
              "0.0234", "Yellow", "Mellow", "elbow"]
          }

        end
        
      end
      
    end


  end

end