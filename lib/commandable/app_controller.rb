module Commandable

  # A helper to display the read me file and generate an example app
  class AppController

    class << self
      extend Commandable

      # Displays the readme file
      command "displays the readme file", :default
      def readme
        `open #{File.expand_path((File.dirname(__FILE__) + '/../../readme.md'))}`
      end

      command "Copies the test classes to a folder so\nyou can see a bunch of small examples"
      # Copies the test classes to a folder so you can see a bunch of small examples
      def examples(path="./examples")
        copy_dir(File.expand_path(File.dirname(__FILE__) + '/../../spec/source_code_examples'),path)
      end

      command "Will raise a programmer error, not a user error\nso you can see what happens when you have bad code"
      # Causes an error so you can see what it will look like if you have an error in your code.
      def error
        raise Exception, "An example of what an error looks like if you make a mistake using Commandable."
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