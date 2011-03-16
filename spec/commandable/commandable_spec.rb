require 'spec_helper'

describe Commandable do

  before(:each) {Commandable.reset_all}

  context "basic functionality" do

    before(:each) { load 'test_class1.rb' }

    context "when clearing values" do
      specify { lambda{Commandable.clear_commands}.should_not raise_error}
      specify { lambda{Commandable.reset_all}.should change{Commandable.commands.length}.from(2).to(1) }
    end

    context "when adding command to methods" do
      specify { lambda{load 'test_class1.rb'}.should_not raise_error }
    end

    context "when checking syntax" do
    
      it "shouldn't rasie an error if nothing more than 'switch' is used" do
        lambda{load 'no_description.rb'}.should_not raise_error(Commandable::SyntaxError)
      end
    
      it "rasies an error if no method follows a description" do
        lambda{load 'bad_class1.rb'}.should raise_error(Commandable::SyntaxError)
      end

    end

    context "when enumerating" do
    
      it "is enumerable using #each" do
        lambda{Commandable.each {|x|}}.should_not raise_error
      end
    
      it "allows access to methods using []" do
        lambda{Commandable["method1"]}.should_not raise_error
      end
    
      context "when using []" do
    
        specify { Commandable["method1"].should_not be_nil }
        specify { Commandable[:method1].should_not be_nil }
        specify { lambda{Commandable[1]}.should raise_error }
        specify { lambda{Commandable[String]}.should raise_error }
      
        context "when using a variable" do

          specify {
            method1 = "method1"
            Commandable[method1].should_not be_nil
          }

          specify {
            method1 = :method1
            Commandable[method1].should_not be_nil
          }
      
        end
      
      end
  
    end
  
    context "when accessing method information" do
    
      it "uses a string in #[] to access methods by name" do
        lambda{Commandable["method1"]}.should_not raise_error
      end
    
    end
  
    context "when accessing method descriptions" do

      it "uses :descriptions" do
        Commandable["method1"][:description].should == "does some stuff"
      end
    
    end

    context "when reading class names" do
     
      it "uses :class" do
        Commandable["method1"][:class].should == "TestClass1"
      end
         
      it "reads the fully qualified name including parent modules and classes" do
        load 'deep_class1.rb' 
        Commandable["deep_method1"][:class].should == "TopModule::ParentClass::DeepClass1"
      end

    end
    
  end 

  context "when reading the method parameters" do
    
    before(:each) { load 'parameter_class1.rb' }
    
    context "when it has required parameters" do
      specify{ Commandable[:foo][:argument_list].should == "int_arg1 number_arg2" }
    end
    
    context "when it has optional parameters" do
      specify {Commandable[:bar][:argument_list].should == %q{int_arg1 [string_arg2="Number 42"]} }
      specify {Commandable[:qux][:argument_list].should == %q{[string_arg1="1492"] [string_arg2="I'm a tricky one"]} }
    end
    
    context "when it has greedy parameters" do
      specify {Commandable[:baz][:argument_list].should == %q{number_arg1 [string_arg2="blorp"] *array_arg3} }
    end
    
    context "when it has an instance method" do
      specify {Commandable[:foo][:class_method].should be_false}
    end
    
    it "saves the list of parameters" do
      Commandable[:foo][:parameters].should == [[:req, :int_arg1], [:req, :number_arg2]]
    end
    
    
  end

  context "when using class methods" do
    
    before(:each) { load 'class_methods.rb' }

    specify { Commandable["class_method"].should_not be_nil }
    specify { Commandable["class_method"][:argument_list].should == "string_arg1" }
    specify { Commandable["class_method2"][:argument_list].should == "integer_arg1" }

    context "grouped class methods" do
      
      before(:each) { 
        load 'class_methods_nested.rb' 
      }
     
      specify{ Commandable[:class_foo][:argument_list].should == "int_arg1 number_arg2" }
      specify {Commandable[:class_bar][:argument_list].should == %q{int_arg1 [string_arg2="Number 42"]} }
      specify {Commandable[:class_qux][:argument_list].should == %q{[string_arg1="1492"] [string_arg2="I'm a tricky one"]} }
      specify {Commandable[:class_baz][:argument_list].should == %q{number_arg1 [string_arg2="blorp"] *array_arg3} }
      specify {Commandable[:class_quuxx][:argument_list].should == %q{decimal_arg1 *array_arg2 &block_arg3} }
    
    end
    
    it "knows it is a class method" do
      Commandable["class_method"][:class_method].should be_true
    end
    
  end

  context "when there is a default command" do
    
    before (:each) { load 'default_method.rb' }
    
    it "sets a command as default" do
      Commandable[:default_method][:default].should == true
    end
    
    it "raises an error if more than one command is set as default" do
      lambda{load 'default_method_bad.rb'}.should raise_error(Commandable::ConfigurationError)
    end
    
    it "executes the default command if no command is given" do
      execute_output_ary(["Klaatu"]).should == ["default method called: Klaatu"]
    end
    
    it "executes a default method and a second command" do
      execute_output_ary(["Klaatu", "not_a_default_method", "28"]).sort.should == [
        "default method called: Klaatu",
        "not a default method: Cleveland", "28"].sort
    end
    
  end

  context "when there are no command line parameters" do
    
    it "prints help info when there isn't a default command" do
      execute_output_s([]).should match(/Usage:/)
    end
    
    context "when there is a default command" do
      it "runs the default command if there are no require parameters " do
        load "default_method.rb"
        execute_output_s([]).should match(/Usage:/)
      end
      it "prints help/usage info if there are require parameters" do
        load "default_method_no_params.rb"
        execute_output_s([]).should match(/default method called, has no params/)
      end
    end
  end

  context "when there is a required command" do
    
    before(:each) {load "required_methods.rb"}
    
    it "raises an error when a required command isn't given" do
      lambda{ Commandable.execution_queue(["non_required_method", "this is some input"]) }.should raise_error(Commandable::MissingRequiredCommandError)
    end
    
  end

  context "when there are deeply nested classes and modules" do
    
    it "executes the command" do
      load "super_deep_class.rb"
      lambda{Commandable.execution_queue(["deep_method1"]).first[:proc].call}.should_not raise_error
    end

    it "returns the correct value" do
      load "super_deep_class.rb"
      Commandable.execution_queue(["deep_method1"]).first[:proc].call.should == "you called a deep method"
    end
    
  end

end