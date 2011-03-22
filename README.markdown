# Commandable
The easiest way to add command line control to your Ruby app. If you don't find **Commandable** incredibly easy to use I will give you one billions dollars!\* (\*not a legally binding offer)

Stop wasting time writing wet command line interpreters or even writing code for the existing ones. Then writing help functions that you have to constantly change as your code changes. Now you can add a single line above an existing method and that method will be available from the command line. Best of all the help/usage instructions are automatically generated using the method itself so if you change your methods the help instructions change without any more effort on your part!

The whole process can take as little as four lines of code:  

* You put a `command "I do something!"` line above your method.
* Add a `require 'commandable'` line somewhere (I'd put it in my bin).
* Then an `extend Commandable` inside your class.
* And finally a call to `Commandable.execute(ARGV)` in your bin file. 

Don't think of **Commandable** as a way to add command line switches to your app but as a way to allow your app to be driven directly from the command line. No more confusing switches that mean one thing in one program and something completely different in another. (Can you believe some apps actually use `-v` for something other than "version" and `-h` for something other than "help?" Madness I say! Madness!)

You can now "use your words" to let people interact with your apps in a natural way.

## Status

2011-03-18 - Final testing and building the example app. I'd wait to use it till I finish the example app. I'm finding new use cases as I do this and correcting some omissions of logic.

## Principle of Least Surprise

I've tried to follow the principle of least surprise so Commandable should just work like you would expect it to. As long as you expect it to work the same way as I do.

## Requirements ##

* Ruby 1.9.2
* *Nix OS (Probably works on Windows but not tested yet)

## Installation  
From the command line:  

    $ [sudo] gem install commandable
    
    
## Usage Instructions

After installing the **Commandable** gem require it somewhere that gets loaded before your class does:

    require 'commandable'

Extend your class with the **Commandable** module:
    
    class Widget
      extend Commandable
    
Then put `command` and a description above the method you want to make accessible. The description is optional but can be helpful
since it's used when automatically building your help/usage instructions.

      command "create a new widget"
      def new(name)
        ...
      end

### The "`command`" command and its options

    command ["description"], [:required], [:default], [:priority=>(0...n)], [:xor[=>:group_name]]

_**command**_ _(required)_  
This is the only thing that's required. It tells **Commandable** to add the method that follows to the list of methods available from the command line.

_**description**_ [optional]  
As you would imagine this is a short description of what the method does. You can have multiple lines by using a new line, `\n`, in the description and your description will be lined up properly. This prints in the help/usage instructions when a user calls your programing using the command "help" or if they try to issue a command that doesn't exist. Help instructions will also print if they try to use your app without any parameters (if there isn't a default method that doesn't require parameters.).

_**:required**_ [optional]  
You can mark a method as required and the user must specify this command and any required parameters every time they run your app. Note that while you can have a method marked as both :default and :required that would be kind of pointless since :required means they have to type out the name of the function and :default means they don't.

_**:default**_ [optional]  
You can have one and only one default method. This method will be called if your app is called with just parameters or if the first command line parameter isn't a command. The user can still give more commands after the parameters for the default command too.
 
For instance say your default method is :foo that takes one parameter and you have another method called :bar that also takes one parameter. A user could do this:

    yourapp "Some Parameter" bar "A parameter for bar"

Just be aware that if they give an option that has the same name as a function the app will think it's a command.

_**priority=>n**_ [optional]  
This optional setting allows you to assign priorities to your methods so if you need them to be executed in a specific order, regardless of how the user specifies them on the command line, you can use this. Then when you execute the command line or ask for a queue of commands they will be sorted for you by priority.

The higher the priority the sooner the method will be executed. If you do not specify a priority a method will have a priority of 0, the lowest priority. 

Note that you can have a default method with a lower priority than a non-default method.

_**:xor[=>:whatever]**_ [optional]  
The :xor parameter allows you to configure a group of methods as mutually exclusive, i.e. if method1 and method2 are in the same :xor group the user of your application can only call one of them at a time.

You can use just the :xor symbol and the method will be put into the default XOR group, called :xor so :xor=>:xor, but if you need multiple XOR groups you can specify a group name by using a hash instead of just the :xor symbol.

The XOR group name will be printed in the front to the description text so it's probably a good idea to use :xor as the prefix.


### Parameter lists
The parameter lists for each method that are printed out in the usage/help instructions are built using the names you give them so you should make sure to use descriptive names. Also keep in mind that all command line parameters are strings so you need to deal with that inside your methods if what you really want is a number.

If none of your methods have parameters then there won't be any reference to parameters in the help/usage instructions.

### A complete class

A complete class might look like this:

    require 'commandable'

    class Widget
      extend Commandable

      command "create a new widget", :default, :priority=>10
      def new(name)
        "You made a widget named: #{name}"
      end

      command "destroy an existing widget", :xor
      def disassemble(name)
        "No dissaemble #{name}! #{name} is alive!"
      end
      
      command "spend lots of money to update a widget", :xor
      def upgrade(name)
        "You just gave #{name} a nice new coat of paint!"
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

If you want to do a block of class commands using `class << self` you need to put `extend Commandable` inside the block:

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

### Automatic usage/help generation ###

One of the great features of **Commandable** is that it will automatically create usage instructions based on your methods and the descriptions you provide for them. The `help` command is also added for you automatically. If your app has no default or it has a default command that requires parameters the help/usage instructions will be printed if a user just runs your app without any input.

A typical help output looks something like this:  

  Commandable - The easiest way to add command line control to your app.
  Copyrighted free software - Copyright (c) 2011 Mike Bethany.
  Version: 0.2.0

  Usage: commandable <command> [parameters] [<command> [parameters]...]

  Command Parameters Description
    error            : Will raise a programmer error, not a user error
                       so you see what happens when you have bad code
 examples [path]     : Copies the test classes to a folder so
                       you can see a bunch of small examples
   readme            : displays the readme file (default)
        v            : <xor> Application Version
  version            : <xor> Application Version
   widget [path]     : Copies a fully working app demonstrating how
                       to use Commandable with RSpec and Cucumber
     help            : you're looking at it now



### Complete demonstration app and some example classes ###
For a fully working example with RSpec and Cucumber tests run this command:

    $ commandable widget [path]

If you would like to see a bunch of simple classes that demonstrate its uses run:

    $ commandable examples [path]

### Commandable Options

There are the basic options you will want to be aware of. Specifically you really want to set `Commandable#app_name` and `Commandable#app_info` so that the help/usage instructions are fully fleshed out.

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
    
    Commandable.verbose_parameters = true
    # Will print:
    command arg1 [arg2="default value"]

    Commandable.verbose_parameters = false
    # Will print:
    command arg1 [arg2]

### Colorized Output Options

The help information can be colored using the standard ANSI escape commands found in the `term-ansicolor-hi` gem. The `term-ansicolor-hi` gem it installed as a dependency but just in case you can install it yourself by running:

    $ [sudo] gem install term-ansicolor-hi

Then you can do something like this:

    require 'term/ansicolor'
    
    c = Term::ANSIColorHI
    
    Commandable.color_app_info           = c.intense_white  + c.bold
    Commandable.color_app_name           = c.intense_green  + c.bold
    Commandable.color_command            = c.intense_yellow
    Commandable.color_description        = c.intense_white
    Commandable.color_parameter          = c.intense_cyan
    Commandable.color_usage              = c.intense_black   + c.bold
    
    Commandable.color_error_word         = c.intense_black   + c.bold
    Commandable.color_error_name         = c.intense_red     + c.bold
    Commandable.color_error_description  = c.intense_white   + c.bold

###Color options 

**Commandable.color\_output**  
_default = true_  
Set to false to disable colorized help/usage instructions. You might find it really, really annoying...

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
The color the word "command" and the commands themselves will be in the help message

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

There are two ways of using **Commandable** to run your methods. You can use its built in execute method to automatically run whatever is entered on the command line or you can have **Commandable** build an array of procs that you can execute yourself. This allows you to have finer grain control over the execution of the commands as you can deal with the return values as you run each command.

### The Easy way

**Commandable#execution_queue(ARGV)**

Now that you've added a command to a method you can send the command line arguments (ARGV) to `Commandable#execution_queue` and it will generate an array of procs you should run sorted in the order of priority you specified when creating the commands.

    # execution_queue returns an array of hashes which 
    # in turn  contains the method name keyed to :method
    # and a proc key to, you guessed it, :proc
    # It looks like this:
    # [{:method => :method_name, :xor=>(:xor group or nil), :parameters=>[...], :priority, :proc => #<proc:>}, ...]
    #
    # The array is automatically sorted by priority (higher numbers first, 10 > 0)

    # First get the array of commands
    command_queue = Commandable.execution_queue(ARGV) # no need to give it ARGV, it's there for testing
    
    return_values = (command_queue.shift)[:proc].call
    # do something with the return values
   
    # check for more values however you want
    more_return_values = command_queue.shift[:proc].call unless command_queue.empty?

If you need a little more control:
    
    # First get the array of commands
    command_queue = Commandable.execution_queue(ARGV) # no need to give it ARGV

    # Loop through the array calling the commands and dealing with the results
    command_queue.each do |cmd|

      # If you need more data about the method you can
      # get the method properties from Commandable[]
      method_name = cmd[:method]
      description = Commandable[method_name][:description]
      puts description

      return_values = cmd[:proc].call

      case method_name
        when :some_method
          # do something with the return values
          # based on it being some_method
        when :some_other_method
          # do something with the return values
          # based on it being some_other_method
        else
          # do something by default
      end
      
    end
    
### The easiest way

**Commandable.execute(ARGV)**

The easiest way to use **Commandable** is to just let it do all the work. This works great if all you need to do is make your methods available from the command line. You can also design a controller class with **Commandable** in mind and run all you command from there.

When you call the `Commandable#execute` method it will return an array of hashes for each method called. Each hash in the array contains the method name and its return values.  

    [:method_name=>[return,values,array], :method_name2=>[return,values,array],...] 

Simply configure your bin file to run `Commandable#execute`:

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


I actually prefer to create a separate file for my **Commandable** configuration and load it in my apps main file in the `lib` directory. Just make sure you load the **Commandable** configuration file first. For a complete example of this run `commandable widget [path]` and it will copy the example app to the directory you specify.

## In closing... ##

One really cool thing about this design is you can extend another app and add your own command line controls without having to crack open their code. The other app doesn't even have to use **Commandable**. You can just write your own methods that call the methods of the original program.

I should also say the code is really, really ugly right now. Thats the very next thing I will be working on for this project. This is the "rough draft" version that works perfectly well but is very ugly code-wise. I needed to use it right now so am putting it out in beta.

If you have any questions about how the code works I've tried to give as much info in these docs as possible but I am also an OCD level commenter so you should be able to find fairly good explanations of what I'm doing in the code.

Most of all it should be simple to use so if you have any problems please drop me a line. Also if you make any changes please send me a pull request. I hate people that don't respond to them, even to deny them, so I'm pretty good about that sort of thing.


## To Do

Still working on for this version:

* Finish **Widget** example app. It will be in the release version but I want to release a beta so I can test the gem via RubyGems.

###Next version:

* Needs a massive refactoring.
* Generator to add Commandable support to your app.
* Reorganize docs to be more logical and less the result of my scribblings as I develop.
* Try to figure out how to trap `alias` without an additional `command` use
* Better formatting of help instructions, the existing one is fairly ugly.
* Use comments below `command` as the description text so you don't have to repeat yourself to get RDoc to give you docs for your functions.
* Clean up RSpecs. I'm doing too many ugly tests of internal state instead of specifying behavior.
* Allow sorting of commands alphabetically or by priority

###Future versions:

* Accepting your suggestions...
* Make the help/usage directions format available to programmers without having to hack the code.
* More edge case testing.
* Allow optional parameters values to be reloaded so changing things like verbose_parameters makes the command list change. (**very** low priority)


.