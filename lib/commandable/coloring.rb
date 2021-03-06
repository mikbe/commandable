require 'term/ansicolor'

module Commandable

  class << self

    # If the output will be colorized or not
    attr_accessor :color_output

    # What color the app_info text will be in the help message
    attr_accessor :color_app_info
    # What color the app_exe will be in the usage line in the help message
    attr_accessor :color_app_exe
    # What color the word "command" and the commands themselves will be in the help message
    attr_accessor :color_command
    # What color the description column header and text will be in the help message
    attr_accessor :color_description
    # What color the word "parameter" and the parameters themselves will be in the help message
    attr_accessor :color_parameter
    # What color the word "Usage:" will be in the help message
    attr_accessor :color_usage

    # What color the word "Error:" text will be in error messages
    attr_accessor :color_error_word
    # What color the friendly name of the error will be in error messages
    attr_accessor :color_error_name
    # What color the error description will be in error messages
    attr_accessor :color_error_description

    # If the screen should be cleared before printing help
    attr_accessor :clear_screen

    # What escape code will be used to clear the screen
    attr_accessor :clear_screen_code
    
    # Resets colors to their default values and disables color output
    def reset_colors
      @color_output = false

      #Term::ANSIColor.coloring = true
      c = Term::ANSIColor
      @color_app_info           = c.intense_white  + c.bold
      @color_app_exe            = c.intense_green  + c.bold
      @color_command            = c.intense_yellow
      @color_description        = c.intense_white
      @color_parameter          = c.intense_cyan
      @color_usage              = c.intense_black   + c.bold
    
      @color_error_word         = c.intense_black   + c.bold
      @color_error_name         = c.intense_red     + c.bold
      @color_error_description  = c.intense_white   + c.bold
    
      @color_bold               = c.bold
      @color_reset              = c.reset
    end
    
    # Resets the escape code used for screen clearing and disables screen clearing.
    def reset_screen_clearing
      @clear_screen = false
      @clear_screen_code = "\e[H\e[2J"
    end

    private
    
    # Changes the colors used when printing the help/usage instructions to those set by the user.
    def set_colors
      if @color_output 
        @c_app_info           = @color_app_info
        @c_app_exe            = @color_app_exe
        @c_command            = @color_command
        @c_description        = @color_description
        @c_parameter          = @color_parameter
        @c_usage              = @color_usage
      
        @c_error_word         = @color_error_word
        @c_error_name         = @color_error_name
        @c_error_description  = @color_error_description
      
        @c_bold               = @color_bold
        @c_reset              = @color_reset
      else
        @c_app_info, @c_app_exe, @c_command, 
        @c_description, @c_parameter, @c_usage, 
        @c_bold, @c_reset, @c_error_word, 
        @c_error_name, @c_error_description = [""]*11
      end
    end

    # Changes the screen clearing code used when printing the help/usage instructions to the one set by the user.
    def set_screen_clear
      if @clear_screen
        @s_clear_screen_code = @clear_screen_code 
      else
        @s_clear_screen_code = ""
      end
    end

  end
  
end