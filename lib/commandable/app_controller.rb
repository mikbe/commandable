module Commandable
  
  # A helper to display the read me file and generate an example app
  class AppController
    WIDGET_GITHUB ||= "://github.com/mikbe/widget"

    class << self
      extend Commandable
 
      # Displays the readme file
      command "displays the readme file", :default
      def readme
        `open #{File.expand_path((File.dirname(__FILE__) + '/../../readme.markdown'))}`
      end
      
      command "Downloads a fully working app demonstrating how\nto use Commandable with RSpec and Cucumber"
      # Creates a simple example app demonstrating a fully working app
      def widget(path="./widget")
        # Test for Git
        unless git_installed?
          puts "Git must be installed to download Widget (You're a developer and you don't have Git installed?)"
          return
        end
        # Git already has all of its own error trapping so
        # it would be horrible coupling and duplication
        # of effort to do anything on my end for failures.
        puts "\nUnable to download Widget. You can find the souce code here:\nhttps#{WIDGET_GITHUB}" unless download_widget(path) == 0
      end

      # Downloads Widget from the git repository
      # This is external to the widget command so it can be stubbed for testing
      def download_widget(path)
        `git clone git#{WIDGET_GITHUB}.git #{path}`
        $?.exitstatus
      end

      # Checks to see if Git is installed
      # This is external to the widget command so it can be stubbed for testing
      def git_installed?
        !`git --version`.chomp.match(/^git version/i).nil?
      end
      
      command "Copies the test classes to a folder so\nyou can see a bunch of small examples"
      # Copies the test classes to a folder so you can see a bunch of small examples
      def examples(path="./examples")
        copy_dir(File.expand_path(File.dirname(__FILE__) + '/../../spec/source_code_examples'),path)
      end

      command "Will raise a programmer error, not a user error\nso you can see what happens when you have bad code"
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
    
      private 
      
      def copy_dir(source, dest)
        files = Dir.glob("#{source}/**")
        mkdir_p dest
        cp_r files, dest
      end

      
    end
    
    
    
  end
  
end


