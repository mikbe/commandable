require 'term/ansicolorhi'
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
  
    # Used when building the usage line, e.g. Usage: app_exe [command] [parameters]
    attr_accessor :app_exe
  
    # If optional parameters show default values, true by default
    attr_accessor :verbose_parameters
  
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
    
    # An array of methods that can be executed from the command line
    def commands
      @@commands.dup
    end
    
    # A hash of instances created when calling instance methods
    # It's keyed using the class name: {"ClassName"=>#<ClassName:0x00000100b1f188>}
    def class_cache
      @@class_cache
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
      @app_exe = nil
      @verbose_parameters = true
      @@default_method = nil
      @@class_cache = {}
    end
    
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
      array.unshift ("\e[2A" + @c_app_info + Commandable.app_info + @c_reset) if Commandable.app_info
      array.unshift "\e[H\e[2J"
      
      header_text = " #{" "*(max_command-cmd_length)}#{@c_command + @c_bold}Command#{@c_reset} "
      header_text += "#{@c_parameter + @c_bold}Parameters #{@c_reset}#{" "*(max_parameter-parm_length)}" if max_parameter > 0
      header_text += "#{@c_description + @c_bold}Description#{@c_reset}"
      
      array << header_text
      
      array += @@commands.keys.collect do |key|
        default = (@@default_method and key == @@default_method.keys[0]) ? @color_bold : ""
        
        help_line  = " #{" "*(max_command-key.length)}#{@c_command + default + key.to_s + @c_reset}"+
                     " #{default + @c_parameter + @@commands[key][:argument_list] + @c_reset}"
        help_line += "#{" "*(max_parameter-@@commands[key][:argument_list].length)} " if max_parameter > 0
        
        # indent new lines
        description = @@commands[key][:description].gsub("\n", "\n" + (" "*(max_command + max_parameter + (max_parameter > 0 ? 1 : 0) + 4)))
        
        help_line += ": #{default + @c_description}#{"<#{@@commands[key][:xor]}> " if @@commands[key][:xor]}" +
                     "#{description}" +
                     "#{" (default)" unless default == ""}#{@c_reset}" 
      end
      array << nil
    end
    
    # A wrapper for the execution_queue that runs the queue and traps errors. 
    # If an error occurs inside this method it will print out a complete.
    # of availavle methods with usage instructios and exit gracefully.
    def execute(argv)
      begin
        command_queue = execution_queue(argv)
        command_queue.each do |com|
          puts com[:proc].call
        end
      rescue Exception => exception
        if exception.respond_to?(:friendly_name)
          set_colors
          puts help("\n  #{@c_error_word}Error:#{@c_reset} #{@c_error_name}#{exception.friendly_name}#{@c_reset}\n  #{@c_error_description}#{exception.message}#{@c_reset}\n\n")
        else
          puts "\n Bleep, bloop, bleep! Danger Will Robinson! Danger!"
          puts "\n Error: #{exception.inspect}"
          puts "\n Backtrace:"
          puts exception.backtrace.collect{|line| " #{line}"}
          puts
        end
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
      
      # Parse the command line into methods and their parameters
      arguments.each do |arg|
        if Commandable[arg]
          last_method = arg.to_sym
          method_hash.merge!(last_method=>[])
        else
          unless last_method
            default = find_by_subkey(:default)

            # Raise an error if there is no default method and the first item isn't a method
            raise UnknownCommandError, arguments.first if default.empty?
            
            # Raise an error if there is a default method but it doesn't take any parameters
            raise UnknownCommandError, (arguments.first) if default.values[0][:argument_list] == ""
            
            last_method = default.keys.first
            method_hash.merge!(last_method=>[])
          end
          method_hash[last_method] << arg
        end
        @@commands.select do |key, value|
          raise MissingRequiredCommandError, key if value[:required] and method_hash[key].nil?
        end
      end
      #puts "method_hash: #{method_hash}" if method_hash.to_s.include?("some_accesor")
      
      # Build an array of procs to be called for each method and its given parameters
      proc_array = []
      method_hash.each do |meth, params|
        command = @@commands[meth]

        if command[:parameters] && !command[:parameters].empty?
          
          #Change the method name for attr_writers
          meth = "#{meth}=" if command[:parameters][0][0] == :writer
        
          # Get a list of required parameters and make sure all of them were provided
          required = command[:parameters].select{|param| [:req, :writer].include?(param[0])}
          required.shift(params.count)
          raise MissingRequiredParameterError, {:method=>meth, :parameters=>required.collect!{|meth| meth[1]}.to_s[1...-1].gsub(":","")} unless required.empty?
        end
        
        # Test for duplicate XORs
        proc_array.select{|x| x[:xor] and x[:xor]==command[:xor] }.each {|bad| raise ExclusiveMethodClashError, "#{meth}, #{bad[:method]}"}

        klass = Object
        command[:class].split(/::/).each { |name| klass = klass.const_get(name) }
        ## Look for class in class cache
        unless command[:class_method]
          klass = (@@class_cache[klass.name] ||= klass.new)
        end
        proc_array << {:method=>meth, :xor=>command[:xor], :parameters=>params, :priority=>command[:priority], :proc=>lambda{klass.send(meth, *params)}}
      end
      proc_array.sort{|a,b| a[:priority] <=> b[:priority]}.reverse
    
    end
   
    # Set colors to their default values
    def reset_colors
      # Colors - off by default
      @color_output      ||= true
      # Build the default colors
      Term::ANSIColorHI.coloring = color_output
      c = Term::ANSIColorHI
      @color_app_info           = c.intense_white  + c.bold
      @color_app_exe           = c.intense_green  + c.bold
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
    
    # Changes the colors used when print the help/usage instructions to those set by the user.
    def set_colors
      if color_output
        @c_app_info           = @color_app_info
        @c_app_exe           = @color_app_exe
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
        @c_app_info, @c_app_exe, @c_command, @c_description,
        @c_parameter, @c_usage, @c_bold, @c_reset, @c_error_word,
        @c_error_name, @c_error_description = [""]*12
      end
    end

  end
  
  # inititialize the Commandable's settings when it's loaded
  reset_all

  private 
  
  # This is where the magic happens!
  # It lets you add a method to the list of command line methods
  def command(*cmd_parameters)

    @@attribute = nil
    @@method_file = nil
    @@method_line = nil
    @@command_options = {}
    
    # Include Commandable in singleton classes so class level methods work
    include Commandable unless self.include? Commandable
    
    # parse command parameters
    while (param = cmd_parameters.shift)
      case param
        when Symbol
          if param == :xor
            @@command_options.merge!(param=>:xor)
          else
            @@command_options.merge!(param=>true)
          end
        when Hash
          @@command_options.merge!(param)
        when String
          @@command_options.merge!(:description=>param)
      end
    end
    @@command_options[:priority] ||= 0
    
    # only one default allowed
    raise ConfigurationError, "Only one default method is allowed."  if @@default_method and @@command_options[:default]
    
    set_trace_func proc { |event, file, line, id, binding, classname|

      @@attribute = id if [:attr_accessor, :attr_writer].include?(id)
      
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
    
    if @@attribute
      argument_list = "value"
      meth = meth.to_s.delete("=").to_sym if @@attribute == :attr_writer
    else
      argument_list = parse_arguments(@@command_options[:parameters])
    end
    @@command_options.merge!(:argument_list=>argument_list,:class => self.name)
    
    @@commands.merge!(meth => @@command_options)
    @@default_method = {meth => @@command_options} if @@command_options[:default]

    @@commands.sort.each {|com| @@commands.merge!(com[0]=>@@commands.delete(com[0]))}
    
    @@commands.merge!(HELP_COMMAND.dup) # makes sure the help command is always last
    @@command_options = nil
    @@attribute = nil
  end

  # Trap method creation after a command call 
  def method_added(meth)
    set_trace_func(nil)
    return super(meth) if meth == :initialize || @@command_options == nil
    
    if @@attribute
      #synthesize parameter
      @@command_options.merge!(:parameters=>[[:writer, :value]],:class_method=>false)
    else
      # create parameter
      @@command_options.merge!(:parameters=>self.instance_method(meth).parameters,:class_method=>false)
    end
    
    add_command(meth)
  end
  
  # Trap class methods too
  def singleton_method_added(meth)
    set_trace_func(nil)
    return super(meth) if meth == :initialize || @@command_options == nil
    @@command_options.merge!(:parameters=>method(meth).parameters, :class_method=>true)
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
    File.open(file).each do |line_text|
      current_line += 1
      return line_text.strip if current_line == line_number
    end
  end
  
  # Parses a method defition for the optional values of given argument.
  def parse_optional(method_def, argument)
    method_def.scan(/#{argument}\s*=\s*("[^"\r\n]*"|'[^'\r\n]*'|[0-9]*)/)[0][0]
  end

end
