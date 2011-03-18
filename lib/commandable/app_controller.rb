module Commandable
  
  # A helper to display the read me file and generate an example app
  class AppController
    
    class << self
      extend Commandable
 
      # Displays the readme file
      command "displays the readme file", :default
      def readme
        `open #{File.expand_path((File.dirname(__FILE__) + '/../../readme.markdown'))}`
      end
      
      command "Copies a fully working app demonstrating how\nto use Commandable with RSpec and Cucumber"
      # Creates a simple example app demonstrating a fully working app
      def widget(path="./widget")
        puts "This feature hasn't been added yet. I'm working on it now and it will be in the release version."
      end
      
      command "Copies the test classes to a folder so\nyou can see a bunch of small examples"
      # Copies the test classes to a folder so you can see a bunch of small examples
      def examples(path="./example_classes")
        FileUtils.copy_dir(File.expand_path(File.dirname(__FILE__) + '/../../spec/source_code_examples'),path)
      end

      command "Will raise a programmer error, not a user error\nso you see what happens when you have bad code"
      # Causes an error so you can see what it will look like if you have an error in your code.
      def error
        raise Exception, "An example of a non-user error caused by your bad code trapped in Commandable.execute()"
      end
 
      command "Application Version", :xor
      # Version
      def v
        puts "Commandable: #{Commandable::VERSION}"
      end
      command "Application Version", :xor
      alias :version :v
      
    end
    
  end
  
end


