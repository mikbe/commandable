require 'set'

# Extending your class with this module allows you to 
# use the #command method above your method. 
# This makes them executable from the command line.
module Commandable

  class << self

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
    
    # A wrapper for the execution_queue that runs the queue and traps errors. 
    # If an error occurs inside this method it will print out a complete list
    # of availavle methods with usage instructions and exit gracefully.
    #
    # If you do not want the output from your methods to be printed out automatically
    # run the execute command with silent set to anything other than false or nil.
    def execute(argv, silent=false)
      begin
        command_queue = execution_queue(argv)
        command_queue.each do |com|
          return_value = com[:proc].call
          puts return_value if !silent || com[:method] == :help
        end
      rescue SystemExit => kernel_exit
        Kernel.exit kernel_exit.status
      rescue Exception => exception
        if exception.respond_to?(:friendly_name)
          set_colors
          puts help("\n  #{@c_error_word}Error:#{@c_reset} #{@c_error_name}#{exception.friendly_name}#{@c_reset}\n  #{@c_error_description}#{exception.message}#{@c_reset}\n\n")
        else
          puts exception.inspect
          puts exception.backtrace.collect{|line| " #{line}"}
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
        # Test for missing required switches
        @@commands.select do |key, value|
          if value[:required] and method_hash[key].nil?
            # If the required switch is also a default have the error be a missing parameter instead of a missing command
            if value[:default]
              method_hash.merge!(key=>[])
            else
              raise MissingRequiredCommandError, key 
            end
          end
        end
      end
      #puts "method_hash: #{method_hash}" if method_hash.to_s.include?("required_default")
      
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
          raise MissingRequiredParameterError, {:method=>meth, :parameters=>required.collect!{|meth| meth[1]}.to_s[1...-1].gsub(":",""), :default=>command[:default]} unless required.empty?
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

    private 
    
    # Look through commands for a specific subkey
    def find_by_subkey(key, value=true)
      @@commands.select {|meth, meth_value| meth_value[key]==value}
    end

  end

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

end