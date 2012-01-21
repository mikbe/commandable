module Commandable
  
  # Parse a method's parameters building the argument list for printing help/usage
  def parse_arguments(parameters)
    parameter_string = ""
    method_definition = nil
    parameters.each do |parameter|
      arg_type = parameter[0]
      arg = parameter[1]
      case arg_type
        when :req
          parameter_string += " #{arg}"
        when :opt
          if Commandable.verbose_parameters
            # figure out what the default value is
            method_definition ||= readline(@@method_file, @@method_line)
            default = parse_optional(method_definition, arg)
            parameter_string += " [#{arg}=#{default}]"
          else
            parameter_string += " [#{arg}]"
          end
        when :rest
          parameter_string += " *#{arg}"
        when :block
          parameter_string += " &#{arg}"
      end
    end
    parameter_string.strip
  end

  # Reads a line from a source code file.
  def readline(file, line_number)
    current_line = 0
    File.open(file).each do |line_text|
      current_line += 1
      return line_text.strip if current_line == line_number
    end
  end
  
  # Parses a method defition for the optional values of given argument.
  def parse_optional(method_def, argument)
    method_def.scan(/#{argument}\s*=\s*("[^"\r\n]*"|'[^'\r\n]*'|[0-9]*)/)[0][0]
  end
  
end