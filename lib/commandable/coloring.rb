module Commandable

  class << self

    # Boolean: If help/usage messages will print in color
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

    # What escape code will be used to clear screen
    attr_accessor :screen_clear

    # Set colors to their default values
    def reset_colors
      @color_output      ||= true

      # Build the default colors
      Term::ANSIColorHI.coloring = color_output
      c = Term::ANSIColorHI
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

      @screen_clear             = "\e[H\e[2J"
    end

    private
    
    # Changes the colors used when print the help/usage instructions to those set by the user.
    def set_colors
      if color_output
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
        @s_clear              = @screen_clear
      else
        @c_app_info, @c_app_exe, @c_command, 
        @c_description, @c_parameter, @c_usage, 
        @c_bold, @c_reset, @c_error_word, 
        @c_error_name, @c_error_description, @s_clear = [""]*12
      end
    end

  end
  
end