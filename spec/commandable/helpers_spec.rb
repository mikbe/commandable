require 'spec_helper'

describe Commandable do

  context "when parsing optional parameters" do
    
    before(:each) {load 'private_methods.rb'}
    
    specify {PrivateMethods.send(:parse_optional, "def bar(x=14243)", "x").should == "14243"} 
    specify {PrivateMethods.send(:parse_optional,"def bar x = 144444", "x").should == "144444"}
    specify {PrivateMethods.send(:parse_optional,"def bar x=12", "x").should == "12"}
    specify {PrivateMethods.send(:parse_optional,'def bar (x="42", y)', "x").should == "\"42\""}
    specify {PrivateMethods.send(:parse_optional,'def bar(y="kjljlj",x="I love Ruby")', "x").should == "\"I love Ruby\""}
    
  end
  
end