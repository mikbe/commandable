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
  
    context "and there is an error in the command line" do
 
      context "because a required parameter is not given" do
        
        context "with a class that doesn't have a default method" do
          specify{lambda{execute_queue(["zaz"]).should raise_error(MissingRequiredParameterError)}}
          specify{lambda{execute_output_s(["zaz"]).should include(/Missing Required/)}}
          specify{lambda{execute_queue(["zaz", "potato"]).should raise_error(MissingRequiredParameterError)}}
          specify{lambda{execute_output_s(["zaz", "potato"]).should include(/Missing Required/)}}
          specify{lambda{execute_queue(["zaz", "potato", "gump"]).should_not raise_error}}
          specify{lambda{execute_output_s(["zaz", "potato", "gump"]).should_not include(/Missing Required/)}}
        end
      
        # When a default method has a required parameter and nothing is given on the command
        # line Commandable will run help so you won't get a MissingRequiredParameterError
        
      end

      context "and the default method does not accept parameters" do
        
        before(:each) {load 'default_method_no_params.rb'}
        
        context "but something that isn't a method is the first thing on the command line" do
          specify {lambda{execute_queue(["potato"])}.should raise_error(Commandable::UnknownCommandError)}
          specify { execute_output_s(["potato"]).should match(/Unknown Command/)} 
        end
        
      end
    
      context "and running procs from the execution queue" do
        it "raises an error if there is an invalid command given" do
          lambda{execute_queue(["fly", "navy"])}.should raise_error(Commandable::UnknownCommandError)
        end
      end
    
      context "and running commands automatically via execute" do
        
        context "and an unknown command is sent" do
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

        context "and an unknown command is sent" do
          
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

    context "and the command line is valid" do
      
      it "does not raise an error" do
        capture_output{Commandable.execute(["foo", "1", "2"])}.to_s.should_not match(/Error:/)
      end

      context "and automatically executing commands" do
        specify {execute_output_ary(["foo", "1", "2.4"]).should == ["1", "2.4"]}
        specify {execute_output_ary(["bar", "234"]).should == ["234", "Number 42"]}
        specify {execute_output_ary(["bar", "39", "potato"]).should == ["39", "potato"]}
        specify {execute_output_ary(["qux"]).should == ["1492", "I'm a tricky one"]}
        specify {execute_output_ary(["qux", "991"]).should == ["991", "I'm a tricky one"]}
        specify {execute_output_ary(["qux", "1821", "Look I've got %special\"characters\" in me"]).should == 
          ["1821", "Look I've got %special\"characters\" in me"]}
      end

      context "and using the execution_queue command" do

        context "and only one command is given" do
          
          it "only has one command in the array" do
            command_queue = Commandable.execution_queue(["foo", "1", "2.4"])
            command_queue.length.should == 1
          end
          
          it "properly parses parameters" do
            command_queue = Commandable.execution_queue(["foo", "1", "2.4"])
            command_queue.first[:parameters].should == ["1", "2.4"]
          end
          
        end
        
        context "and more than one command is given" do
          
          it "has the correct number of commands in the array" do
            command_queue = Commandable.execution_queue(["foo", "1", "2.4", "bar", "71"])
            command_queue.length.should == 2
          end

          it "properly parses parameters" do
            command_queue = Commandable.execution_queue(["foo", "1", "2.4", "bar", "71"])
            command_queue.each do |command|
              command[:parameters].should == ["71"] if command[:method] == :bar
              command[:parameters].should == ["1", "2.4"] if command[:method] == :foo
            end
          end
          
        end
        
      end
      
      context "and there are greedy parameters" do
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
      
      context "when a default method name isn't specified but the required switch is properly given" do
        before(:each){load "default_method.rb"}
        specify{lambda{execute_queue(["phish"])}.should_not raise_error}
        specify{lambda{execute_output_s(["phish"]).should include(/default method called with: phish/)}}
        specify{execute_queue(["not_a_default_method", "potato"]).should include("not a default method, called with: Cleveland, potato") }
        specify{execute_output_s(["not_a_default_method", "phish"]).should include("not a default method, called with: Cleveland, phish")}
      end
      
    end

  end

end