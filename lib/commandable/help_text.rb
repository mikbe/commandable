module Commandable

  # Default command that always gets added to end of the command list
  HELP_COMMAND = {:help => {:description => "you're looking at it now", :argument_list => "", :class=>"Commandable", :class_method=>true}}
  
  class << self
    
    # Describes your application, printed at the top of help/usage messages
    attr_accessor :app_info
  
    # Used when building the usage line, e.g. Usage: app_exe [command] [parameters]
    attr_accessor :app_exe
  
    # If optional parameters show default values, true by default
    attr_accessor :verbose_parameters
    
    # Generates an array of the available commands with a
    # list of their parameters and the method's description.
    # This includes the applicaiton info and app name if given.
    # It's meant to be printed to the command line.
    def help(additional_info=nil)
      
      set_colors
      set_screen_clear
      
      cmd_length = "Command".length
      parm_length = "Parameters".length
      max_command = [(@@commands.keys.max_by{|key| key.to_s.length }).to_s.length, cmd_length].max
      max_parameter = @@commands[@@commands.keys.max_by{|key| @@commands[key][:argument_list].length }][:argument_list].length
      max_parameter = [parm_length, max_parameter].max if max_parameter > 0

      usage_text = "  #{@c_usage}Usage:#{@c_reset} "

      if Commandable.app_exe      
        cmd_text = "<#{@c_command + @c_bold}command#{@c_reset}>"
        parm_text = " [#{@c_parameter + @c_bold}parameters#{@c_reset}]" if max_parameter > 0
        usage_text += "#{@c_app_exe + app_exe + @c_reset} #{cmd_text}#{parm_text} [#{cmd_text}#{parm_text}...]"
      end

      array =  [usage_text, ""]
      
      array.unshift additional_info if additional_info
      array.unshift (@c_app_info + Commandable.app_info + @c_reset) if Commandable.app_info
      array.unshift @s_clear_screen_code
      
      header_text = " #{" "*(max_command-cmd_length)}#{@c_command + @c_bold}Command#{@c_reset} "
      header_text += "#{@c_parameter + @c_bold}Parameters #{@c_reset}#{" "*(max_parameter-parm_length)}" if max_parameter > 0
      header_text += "#{@c_description + @c_bold}Description#{@c_reset}"
      
      array << header_text

      array += @@commands.keys.collect do |key|
        is_default = (@@default_method and key == @@default_method.keys[0])
        default_color =  is_default ? @c_bold : ""

        help_line  = " #{" "*(max_command-key.length)}#{@c_command + default_color + key.to_s + @c_reset}"+
                     " #{default_color + @c_parameter + @@commands[key][:argument_list] + @c_reset}"
        help_line += "#{" "*(max_parameter-@@commands[key][:argument_list].length)} " if max_parameter > 0
        
        # indent new lines
        description = @@commands[key][:description].gsub("\n", "\n" + (" "*(max_command + max_parameter + (max_parameter > 0 ? 1 : 0) + 4)))
        
        help_line += ": #{default_color + @c_description}#{"<#{@@commands[key][:xor]}> " if @@commands[key][:xor]}" +
                     "#{description}" +
                     "#{" (default)" if is_default}#{@c_reset}" 
      end
      array << nil
    end


  end
  
end