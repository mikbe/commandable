require 'set'

# Extending your class with this module allows you to 
# use the #command method above your method. 
# This makes them executable from the command line.
module Commandable

  class << self

    # A wrapper for the execution_queue that runs the queue and traps errors. 
    # If an error occurs inside this method it will print out a complete list
    # of availavle methods with usage instructions and exit gracefully.
    #
    # If you do not want the output from your methods to be printed out automatically
    # run the execute command with silent set to anything other than false or nil.
    def execute(argv=ARGV.clone, silent=false)
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

end