module Commandable

  class << self
    
    # Resets the class to default values clearing any commands
    # and setting the colors back to their default values.
    def reset_all
      clear_commands
      reset_colors
      reset_screen_clearing
      
      @app_info = nil
      @app_exe = nil
      @verbose_parameters = true
      @@default_method = nil
      @@class_cache = {}
    end
  
  end
    
  # Inititializes Commandable's settings when it's first loaded
  reset_all

end