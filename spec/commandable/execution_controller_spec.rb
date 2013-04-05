require 'spec_helper'

describe Commandable do

  before(:each) {Commandable.reset_all}

  context "when using Commandable directly" do

    before(:each) { load 'test_class.rb' }

    it "should use ARGV by default" do
      expect {capture_output{Commandable.execute()}}.to_not raise_error(ArgumentError)
    end

  end

end