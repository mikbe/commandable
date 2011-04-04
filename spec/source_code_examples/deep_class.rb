require "commandable"

module TopModule
  class ParentClass
    class DeepClass
      extend Commandable
      command 'this is a deep method call'
      def deep_method
        "you called a deep method"
      end 
    end
  end
end
