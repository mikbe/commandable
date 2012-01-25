require 'set'

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