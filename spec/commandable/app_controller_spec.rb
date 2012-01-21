require 'spec_helper'

describe Commandable do

  before(:each) {
    Commandable.reset_all
    Commandable.color_output = true
    Commandable.verbose_parameters = false
    Commandable.app_exe = "commandable"
    Commandable.app_info =  
    """
      \e[92mCommandable\e[0m - The easiest way to add command line control to your app.
      Copyrighted free software - Copyright (c) 2011 Mike Bethany.
      Version: #{Commandable::VERSION::STRING}
    """

    # App controller has to be loaded after commandable settings
    # or it won't be able to use the settings
    load 'commandable/app_controller.rb'
  }


end