require 'term/ansicolor'
require 'set'

# This library allows you to incredibly easily make 
# your methods directly available from the command line.
#
# Author::    Mike Bethany  (mailto:mikbe.tk@gmail.com)
# Copyright:: Copyright (c) 2011 Mike Bethany
# License::   Distributed under the MIT licence (See LICENCE file)

# Extending your class with this module allows you to use the #command
# method above your method. This makes them executable from the command line.
module Commandable
  
  # Default command that always gets added to end of the command list
  HELP_COMMAND = {:help => {:description => "you're looking at it now", :argument_list => "", :class=>"Commandable", :class_method=>true}}

  class << self
    
    # Describes your application, printed at the top of help/usage messages
    attr_accessor :app_info
    
    # Used when building the usage line, e.g. Usage: app_name [command] [parameters]
    attr_accessor :app_name
    
    # If optional parameters show default values, true by default
    attr_accessor :verbose_parameters
    
    # Boolean: If help/usage messages will print in color
    attr_accessor :color_output
    # What color the app_info text will be in the help message
    attr_accessor :color_app_info
    # What color the app_name will be in the usage line in the help message
    attr_accessor :color_app_name
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
    
    # An array of methods that can be executed from the command line
    def commands
      @@commands.dup
    end
    
    # Access the command array using the method name (symbol or string)
    def [](index)
      raise AccessorError unless index.is_a? String or index.is_a? Symbol
      @@commands[index.to_sym]
    end 
    
    # Resets the class to default values clearing any commands
    # and setting the color back to their default values.
    def reset_all
      clear_commands
      reset_colors
      @app_info = nil
      @app_name = nil
      @verbose_parameters = true
      @@default_method = nil
    end
    alias :init :reset_all
    
    # Clears all methods from the list of available commands
    # This is mostly useful for testing.
    def clear_commands
      @@commands = HELP_COMMAND.dup
    end
    
    # Convenience method to iterate over the array of commands using the Commandable module
    def each(&block)
      @@commands.each do |key, value|
        yield key => value
      end
    end
    
    # Generates an array of the available commands with a
    # list of their parameters and the method's description.
    # This includes the applicaiton info and app name if given.
    # It's meant to be printed to the command line.
    def help(additional_info=nil)
      
      set_colors
      array =  ["  #{@c_usage}Usage:#{@c_reset} #{@c_app_name + app_name + @c_reset + " <#{@c_command + @c_bold}command#{@c_reset}> [#{@c_parameter + @c_bold}parameters#{@c_reset}] [<#{@c_command + @c_bold}command#{@c_reset}> [#{@c_parameter + @c_bold}parameters#{@c_reset}]...]" if Commandable.app_name}", ""]
      array.unshift additional_info if additional_info
      array.unshift ("\e[2A" + @c_app_info + Commandable.app_info + @c_reset) if Commandable.app_info
      array.unshift "\e[H\e[2J"
      
      cmd_length = "Command".length
      parm_length = "Parameter(s)".length
      max_command = [(@@commands.keys.max_by{|key| key.to_s.length }).to_s.length, cmd_length].max
      max_parameter = [@@commands[@@commands.keys.max_by{|key| @@commands[key][:argument_list].length }][:argument_list].length, parm_length].max
      
      array << " #{" "*(max_command-cmd_length)}#{@c_command + @c_bold}Command#{@c_reset} #{@c_parameter + @c_bold}Parameter(s) #{@c_reset}#{" "*(max_parameter-parm_length)}#{@c_description + @c_bold}Description#{@c_reset}"
      array += @@commands.keys.collect do |key|
        default = (@@default_method and key == @@default_method.keys[0]) ? @color_bold : ""
        " #{" "*(max_command-key.length)}#{@c_command + default + key.to_s + @c_reset} #{default + @c_parameter + @@commands[key][:argument_list] + @c_reset}#{" "*(max_parameter-@@commands[key][:argument_list].length)} : #{default + @c_description}#{@@commands[key][:description]}#{" (default)" unless default == ""}#{@c_reset}" 
      end
      array << nil
    end
    
    # A wrapper for the execution_queue that runs the queue and traps errors. 
    # If an error occurs inside this method it will print out a complete.
    # of availavle methods with usage instructios and exit gracefully.
    def execute(argv)
      begin
        command_array = execution_queue(argv)
        command_array.each do |com|
          puts com[:proc].call
        end
      rescue Exception => exception
        set_colors
        puts help("\n  #{@c_error_word}Error:#{@c_reset} #{@c_error_name}#{exception.friendly_name}#{@c_reset}\n  #{@c_error_description}#{exception.message}#{@c_reset}\n\n")
      end
    end
    
    # Returns an array of executable procs based on the given array of commands and parameters
    # Normally this would come from the command line parameters in the ARGV array.
    def execution_queue(argv)
      arguments = argv.dup
      method_hash = {}
      last_method = nil
      
      if arguments.empty?
        arguments << @@default_method.keys[0] if @@default_method and !@@default_method.values[0][:parameters].flatten.include?(:req)
      end
      arguments << "help" if arguments.empty?
      
      # Parse the commad line into methods and their parameters
      arguments.each do |arg|
        if Commandable[arg]
          last_method = arg.to_sym
          method_hash.merge!(last_method=>[])
        else
          unless last_method
            default = find_by_subkey(:default)
            raise UnknownCommandError, arguments.first if default.empty?
            last_method = default.keys.first
            method_hash.merge!(last_method=>[])
          end
          method_hash[last_method] << arg
        end
        @@commands.select do |key, value| 
          raise MissingRequiredCommandError, key if value[:required] and method_hash[key].nil?
        end
      end

      # Build an array of procs to be called for each method and its given parameters
      proc_array = []
      method_hash.each do |meth, params|
        command = @@commands[meth]
        
        # Test for duplicate XORs
        proc_array.select{|x| x[:xor] and x[:xor]==command[:xor] }.each {|bad| raise ExclusiveMethodClashError, "#{meth}, #{bad[:method]}"}

        klass = Object
        command[:class].split(/::/).each { |name| klass = klass.const_get(name) }
        klass = klass.new unless command[:class_method]
        proc_array << {:method=>meth, :xor=>command[:xor], :parameters=>params, :priority=>@@cmd_parameters[:priority], :proc=>lambda{klass.send(meth, *params)}}
      end
      proc_array.sort{|a,b| a[:priority] <=> b[:priority]}.reverse
    end
   
    # Set colors to their default values
    def reset_colors
      # Colors - off by default
      @color_output      ||= false
      # Build the default colors
      Term::ANSIColor.coloring = true
      c = Term::ANSIColor
      @color_app_info           = c.intense_white  + c.bold
      @color_app_name           = c.intense_green  + c.bold
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
    
    # Look through commands for a specific subkey
    def find_by_subkey(key, value=true)
      @@commands.select {|meth, meth_value| meth_value[key]==value}
    end
    # Look through command subkeys using a hash
    def find_by_subhash(hash)
    
    end
    
    # Changes the colors used when print the help/usage instructions to those set by the user.
    def set_colors
      if color_output
        @c_app_info           = @color_app_info
        @c_app_name           = @color_app_name
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
        @c_app_info, @c_app_name, @c_command, @c_description,
        @c_parameter, @c_usage, @c_bold, @c_reset, @c_error_word,
        @c_error_name, @c_error_description = [""]*12
      end
    end

  end
  init # automatically configure the module when it's loaded

  private 
  
  # Add a method to the list of command line methods
  def command(*cmd_parameters)

    @@method_file = nil
    @@method_line = nil
    @@cmd_parameters = {}
    
    # Include Commandable in singleton classes so class level methods work
    include Commandable unless self.include? Commandable
    
    # parse command parameters
    while (param = cmd_parameters.shift)
      case param
        when Symbol
          if param == :xor
            @@cmd_parameters.merge!(param=>:xor)
          else
            @@cmd_parameters.merge!(param=>true)
          end
        when Hash
          @@cmd_parameters.merge!(param)
        when String
          @@cmd_parameters.merge!(:description=>param)
      end
    end
    @@cmd_parameters[:priority] ||= 0
    
    # only one default allowed
    raise ConfigurationError, "Only one default method is allowed."  if @@default_method and @@cmd_parameters[:default]
    
    set_trace_func proc { |event, file, line, id, binding, classname|

      # Traps the line where the method is defined so we can look up 
      # the method source code later if there are optional parameters
      if event == "line" and !@@method_file
        @@method_file = file
        @@method_line = line
      end
 
      # Raise an error if there is no method following a command definition
      if event == "end"
        set_trace_func(nil)
        raise SyntaxError, "A command was specified but no method follows"
      end
    }
  end

  # Add a method to the list of available command line methods
  def add_command(meth)
    @@commands.delete(:help)
    argument_list = parse_arguments(@@cmd_parameters[:parameters])
    @@cmd_parameters.merge!(:argument_list=>argument_list,:class => self.name)
    @@commands.merge!(meth => @@cmd_parameters)
    @@default_method = {meth => @@cmd_parameters} if @@cmd_parameters[:default]
    @@commands.merge!(HELP_COMMAND.dup) # make sure the help command is always last
  end

  # Trap method creation after a command call 
  def method_added(meth)
    return super(meth) if meth == :initialize
    
    set_trace_func(nil)
    @@cmd_parameters.merge!(:parameters=>self.instance_method(meth).parameters,:class_method=>false)
    add_command(meth)
  end
  
  # Trap class methods too
  def singleton_method_added(meth)
    set_trace_func(nil)
    @@cmd_parameters.merge!(:parameters=>method(meth).parameters, :class_method=>true)
    add_command(meth)
  end

  # Parse a method's parameters building the argument list for printing help/usage
  def parse_arguments(parameters)
    parameter_string = ""
    method_definition = nil
    parameters.each do |parameter|
      arg_type = parameter[0]
      arg = parameter[1]
      case arg_type
        when :req
          parameter_string += " #{arg}"
        when :opt
          if Commandable.verbose_parameters
            # figure out what the default value is
            method_definition ||= readline(@@method_file, @@method_line)
            default = parse_optional(method_definition, arg)
            parameter_string += " [#{arg}=#{default}]"
          else
            parameter_string += " [#{arg}]"
          end
        when :rest
          parameter_string += " *#{arg}"
        when :block
          parameter_string += " &#{arg}"
      end
    end
    parameter_string.strip
  end

  # Reads a line from a source code file.
  def readline(file, line_number)
    current_line = 0
    File.open(file).each { |line_text|
      current_line += 1
      return line_text.strip if current_line == line_number
    }
  end
  
  # Parses a method defition for the optional values of given argument.
  def parse_optional(method_def, argument)
    method_def.scan(/#{argument}\s*=\s*("[^"\r\n]*"|'[^'\r\n]*'|[0-9]*)/)[0][0]
  end

end
