# Commandable
The easiest way to add command line control to your app. If you don't find Commandable incredibly easy to use I will give you one billions dollars!* (*not legally binding)

Stop wasting time writing wet command line interpreters or even writing code for the existing ones. Now you can add a single line above an existing method and that method will be available from the command line. Best of all the help/usage instructions are automatically generated using the method itself.

The whole process can be as little as four lines of code: a line of code above your method, a require for the Commandable gem, an "extend Commandable" in your class, and a call to execute the command line arguments (ARGV) in your bin file. 

Don't think of Commandable as a way to add command line switches to your app but as a way to allow your app to be driven directly from the command line. No more confusing switches that means one thing in one program and something else in another. You can now "use your words" to let people interact with your apps in a natural way.

## Installation  
From the command line:  

    $ [sudo] gem install commandable
    
    
## Usage Instructions

After installing the `Commandable` gem require it:

    require 'commandable'

Extend your class with the `Commandable` module:
    
    class Widget
      extend Commandable
    
Put `command` and a description above a method you want to make accessible. The description is optional but can be helpful
since it's used when automatically building your help/usage instructions.

      command "create a new widget"
      def new(name)
        ...
      end

### The "command" command

    command ["description"], [:required], [:default], [:priority=>[0...n]]

_**command**_  
This is the only thing that's required. It tells Commandable to add the following method to the list of methods available from the command line.

_**description**_  
This will print in the help/usage instructions that get printed when a user calls your programing with the command "help" or if they try to issue a command that doesn't exist.

_**:required**_  
You can mark a method as required and the user must specify the command and any required parameters every time they run your app.

_**:default**_  
You can have one and only one default method. This method will be called if your app is called with just parameters or if the first command line parameter isn't a command. The user can still give more commands after the parameters for the default command too!
 
For instance say your default method is :foo that takes one parameter and you have another method called :bar that also takes one parameter. A user could do this:

    yourapp "Some Parameter" bar "A parameter for bar"

_**priority=>n**_  
This optional setting allows you to assign priorities to your methods so if you need them to be executed in a specific order regardless of how the user specifies them on the command line you can use this and when you execute the command line or ask for a queue of commands they will be sorted for you by priority.

The higher the priority the sooner the method will be executed. If you do not specify a priority a method will have a priority of 0, the lowest priority. 

Note that you can have a default method with a lower priority than a non-default method.

### Parameter lists
The parameter lists for each method that are printed out in the usage/help instructions are are built using the names you give them so you should make sure to use descriptive names. Also keep in mind that all command line parameters are strings so you need to deal with that inside your methods if what you really want is a number.

### A complete class

A complete class might look like this:

    require 'commandable'

    class Widget
      extend Commandable

      command "create a new widget"
      def new(name)
        "You made a widget named: #{name}"
      end

    end

#### Class methods
You can also use it on class methods:

    require "commandable"

    class ClassMethods
      extend Commandable

      command 'does some stuff'
      def self.class_method(string_arg1)
        ...
      end
  
      # The first class method will get the command
      command "another one"
      class << self
        def class_method2(integer_arg1)
          ...
        end
      end
    end

If you want to do a block of class commands using class << self you need to put `extend Commandable` inside the block:

    require "commandable"

    class ClassMethodsNested
      class << self
        extend Commandable
  
        command "hello world"
        def class_foo(int_arg1, number_arg2)
          [int_arg1, number_arg2]
        end

        command "look a function"
        def class_bar(int_arg1, string_arg2="Number 42")
          [int_arg1, string_arg2]
        end
      end
    end


Note: Class methods are called directly on the class while instance methods have an instance created for that call. Keep that in mind if you need to share data between calls. In that case you might want to store your data in a model you create outside the execution queue.

### Options

There are basic options you will want to be aware of. Specifically you really want to set Commandable#app\_name and Commandable#app\_info so that the help/usage instructions are fully fleshed out.

**Commandable.app\_name**  
_default = ""_  
Set this and the help instructions will include your application's name.

**Commandable.app\_info**  
_default = ""_  
This is informational text that will print above the help/usage instructions.

**Commandable.verbose\_parameters**  
_default = true_  
If set to false help instructions will not print out default values.  
**Important!** This should only be set once, before any files load. Changing the value after files are loaded will make no difference since parameters are only parsed when the source file loads.
    
    Commandable.verbose_parameters = true (*this is the default)
    # Will print:
    command arg1 [arg2="default value"]

    Commandable.verbose_parameters = false
    # Will print:
    command arg1 [arg2]

### Colorized Output

The help information can be colored using the standard ANSI escape commands found in the term-ansicolor-hi gem.

To get access to the colors use the term-ansicolor-hi gem. It's installed as a dependency but just in case you can install it your self by running this from the command line:

    $ [sudo] gem install term-ansicolor-hi

Then you can do something like this:

    require 'term/ansicolor'
    
    c = Term::ANSIColor
    
    Commandable.color_app_info           = c.intense_white  + c.bold
    Commandable.color_app_name           = c.intense_green  + c.bold
    Commandable.color_command            = c.intense_yellow
    Commandable.color_description        = c.intense_white
    Commandable.color_parameter          = c.intense_cyan
    Commandable.color_usage              = c.intense_black   + c.bold
    
    Commandable.color_error_word         = c.intense_black   + c.bold
    Commandable.color_error_name         = c.intense_red     + c.bold
    Commandable.color_error_description  = c.intense_white   + c.bold

####Color options 

**Commandable.color\_output**  
_default = false_  
Set to true to enable colorized help/usage instructions.

**Commandable.color\_app\_info**  
_default = intense\_white_ + bold  
The color the app_info text will be in the help message

**Commandable.color\_app\_name**  
_default = intense\_green_ + bold  
The color the app_name will be in the usage line in the help message

**Commandable.color\_command**  
_default = intense\_yellow_  
The color the word "command" and the commands themselves will be in the help message

**Commandable.color\_description**  
_default = intense\_white_  
color the word "command" and the commands themselves will be in the help message

**Commandable.color\_parameter**  
_default = intense\_cyan_  
The color the word "parameter" and the parameters themselves will be in the help message

**Commandable.color\_usage**  
_default = intense\_black_ + bold  
The color the word "Usage:" will be in the help message.

**Commandable.color\_error\_word**  
_default = intense\_white_  
The color the word "Error:" text will be in error messages 

**Commandable.color\_error\_name**  
_default = intense\_cyan_  
The color the friendly name of the error will be in error messages

**Commandable.color\_error\_description**  
_default = intense\_black_ + bold  
The color the error description will be in error messages


### Executing the Command Line

There are two ways of using Commandable to run your methods. You can use its built in execute method to automatically run whatever is sent when running your app or you can have Commandable build an array of procs that you can execute yourself and deal with the return values however you wish.

### The Easy way

**Commandable#execution_queue(ARGV)**

Now that you've added a command to a method you can send the command line arguments (ARGV) to Commandable#execution_queue and it will generate an array of procs you should run sorted in the order of priority you specified when creating the commands.

    # execution_queue returns an array of hashes which 
    # in turn  contains the method name keyed to :method
    # and a proc key to, you guessed it, :proc
    # It looks like this:
    # [{:method => :method_name, :proc => #<proc:>}, ...]
    #
    # The array is automatically sorted by priority (higher numbers first, 10 > 0)

    # First get the array of commands
    command_array = Commandable.execution_queue(ARGV) # no need to give it ARGV, it's there for testing
    
    return_values = (command_array.shift)[:proc].call
    # do something with the return values
   
    # check for more values however you want
    more_return_values = (command_array.shift).call unless command_array.empty?

If you need a little more control:
    
    # First get the array of commands
    command_array = Commandable.execution_queue(ARGV) # no need to give it ARGV

    # Loop through the array calling the commands and dealing with the results
    command_array.each do |cmd|

      # If you need more data about the method you can
      # get the method properties from Commandable[]
      # e.g.
      # method_name = cmd[:method]
      # description = Commandable[method_name][:description]
      # puts description

      return_values = cmd[:proc].call

      case method_name
        when :some_method
          # do somehting with the return values
          # based on it being some_method
        when :some_other_method
          # do somehting with the return values
          # based on it being some_other_method
        else
          # do something by default
      end
      
    end
    
### The easiest way

**Commandable.execute(ARGV)**

The easiest way to use Commandable is to just let it do all the work. This works great if all you need to do is make your methods available from the command line. When you call the Commandable#execute method it will return an array of hashes for each method called. Each hash in the array contains the method name and its return values.  

    [:method_name=>[return,values,array], :method_name2=>[return,values,array],...] 

Simply configure your bin file to run Commandable#execute:

**[your Ruby app directory]/bin/your\_app\_name**

    #!/usr/bin/env ruby
    $LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__) + "/../lib")
    require 'yourappname'
    require 'commandable'
    Commandable.verbose_parameters = false
    Commandable.color_output = true
    Commandable.app_name = "My App"
    Commandable.app_info =
    """
      My App - It does stuff and things!
      Copyright (c) 2011 Acme Inc.
    """
    return_values = Commandable.execute(ARGV)
    # do stuff

# To Do

Still working on:

* Example app.
* Load README from AppController.

###Next version:

* Massive refactoring. This is the "rough draft" version that works perfectly well but is very ugly code-wise. I needed to use it right now so am putting it out in beta.  
* Reorganize docs to be more logical and less the result of my scribblings as I develop.
* Method aliases cleanly added.
* Better formatting of help instructions.

###Future versions:

* Make the help/usage directions format available to programmers without having to hack the code.
* More edge case testing.
* Look at adding ability to save instances across method calls.
* Look at ability to inject instances into the method execution queue.
* Allow optional parameters values to be reloaded so changing verbose_parameters makes the command list change. (**very** low priority)

.