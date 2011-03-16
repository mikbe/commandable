module Commandable
  
  # An error made by the programmer when specifiying a command 
  class SyntaxError < Exception
    # Returns a more print friendly error name
    def friendly_name
      "Internal Syntax Error"
    end
  end

  # A error raised if a user tries to run a command that is not in the commands array
  class UnknownCommandError < StandardError
    # Returns a more print friendly error name
    def friendly_name
      "Unknown Command"
    end
    # Create a new instance of the MissingRequiredCommandError class
    def initialize(msg)
      super("There is no \"#{msg}\" command")
    end
  end

  # A programmer's error raised if setting are specifiying incorrectly, e.g. setting more than one default method
  class ConfigurationError < Exception
    # Returns a more print friendly error name
    def friendly_name
      "Internal Configuration Error"
    end
  end

  # An error raised if a user does not provide a required command
  class MissingRequiredCommandError < StandardError
    # Returns a more print friendly error name
    def friendly_name
      "Missing Required Command"
    end
    # Create a new instance of the MissingRequiredCommandError class
    def initialize(msg)
      super("The required command \"#{msg}\" is missing.")
    end
  end

  # A programmer's error raised if the list of commands is accessed using something other than a string or :symbol
  # This is meant to catch meta-programming errors.
  class AccessorError < Exception
    # Returns a more print friendly error name
    def friendly_name
      "Internal Accessor Error"
    end
    # Create a new instance of the AccessorError class
    def initialize(msg = "You may only access Commandable[] using a string or :symbol" )
      super(msg)
    end
  end
  
end
