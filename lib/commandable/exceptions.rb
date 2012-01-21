module Commandable
  
  # Programmer errors
  
  # An error made by the programmer when specifiying a command 
  class SyntaxError < StandardError
  end

  # A programmer's error raised if setting are specifiying incorrectly, 
  # For example if you set more than one default method.
  class ConfigurationError < StandardError
  end

  # A programmer's error raised if the list of commands is accessed using something other than a string or :symbol
  # This is meant to catch meta-programming errors.
  class AccessorError < StandardError
    # Create a new instance of the AccessorError class
    def initialize(msg = "You may only access Commandable[] using a string or :symbol" )
      super(msg)
    end
  end

  # User errors

  # An error raised if a user does not provide a required command
  class MissingRequiredCommandError < ScriptError
    # Returns a more print friendly error name
    def friendly_name
      "Missing Required Command"
    end
    # Create a new instance of the MissingRequiredCommandError class
    def initialize(msg)
      super("The required command \"#{msg}\" is missing.")
    end
  end


  # An error raised if a user does not provide a required command
  class MissingRequiredParameterError < ScriptError
    # Returns a more print friendly error name
    def friendly_name
      "Missing Required Parmeter"
    end
    # Create a new instance of the MissingRequiredParameterError class
    def initialize(msg)
      super("""
  The #{"default " if msg[:default]}command \"#{msg[:method]}\" is missing the required parameter \"#{msg[:parameters]}\".
  #{"You don't have to specifically say \"#{msg[:method]}\" but you do have to give the parameter." if msg[:default]}"
      )
    end
  end


  # This error is raised if a user gives two or more commands from the same exclusive group
  class ExclusiveMethodClashError < ScriptError
    # Returns a more print friendly error name
    def friendly_name
      "Exclusive "
    end
    # Create a new instance of the MissingRequiredCommandError class
    def initialize(msg)
      super("You may only run one of these commands at a time: \"#{msg}\"")
    end
  end

  # A error raised if a user tries to run a command that is not in the commands array
  class UnknownCommandError < ScriptError
    # Returns a more print friendly error name
    def friendly_name
      "Unknown Command"
    end
    # Create a new instance of the MissingRequiredCommandError class
    def initialize(msg)
      super("There is no \"#{msg}\" command")
    end
  end
  
end