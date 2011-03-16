module Commandable
  
  # A helper to display the read me file and generate an example app
  class AppController
    
    class << self
      extend Commandable
      
      command "displays the readme file"
      # Displays the readme file
      def readme
        `open #{File.expand_path((File.dirname(__FILE__) + '/../../readme.markdown'))}`
      end
      
      command "creates a simple example app"
      # Creates a simple example app
      def make_example(location="./cmd_exp")
      
      end
      
      command "test default" , :default
      def dummy_default(stuff)
        "I am the champion! Of the world! Oh, and you said, #{stuff}"
      end
      
    end
    
  end
  
end


