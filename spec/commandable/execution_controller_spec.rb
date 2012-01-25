require 'spec_helper'

describe Commandable do

  before(:each) {Commandable.reset_all}

  context "when using Commandable directly" do

    before(:each) { load 'test_class.rb' }

    it "should use ARGV by default" do
      Commandable.execute(7)
      expect {capture_output{Commandable.execute()}}.should_not raise_error(ArgumentError)
      expect {capture_output{Commandable.execute(1)}}.should raise_error(TypeError)
    end
    
  end

end