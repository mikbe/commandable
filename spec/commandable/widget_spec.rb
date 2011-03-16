$:.unshift 
require 'spec_helper'

describe Commandable do

  before(:each) {Commandable.reset_all}

  context "create a new widget" do
    
    it "doesn't shit the bed" do
      
      require 'widget'
      #puts Commandable.help
      Commandable.execute(["Johnny5"])
      
    end
    
  end


end