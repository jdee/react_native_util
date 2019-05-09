require 'colored'
require_relative 'core_ext/io'
require_relative 'exceptions'

module ReactNativeConvert
  # Module with utility methods
  module Util
    # Execute the specified command. If output is non-nil, generate a log
    # at that location. Main log (open) is log.
    #
    # @param command Variadic command to be executed
    # @param output [String, Symbol, IO] Output for command (path, IO or a symbol such as :close)
    # @param log [IO, nil] Open IO for main log (nil to suppress logging command to main log)
    # @return nil
    # @raise ExecutionError If the command fails
    def execute(*command, output: STDOUT, log: STDOUT)
      log.log_command command unless log.nil?

      system(*command, %i[err out] => output)

      raise ExecutionError unless $?.success?

      nil
    end

    # Return a Boolean value associated with an environment variable.
    #
    # @param var [#to_s] The name of an environment variable
    # @param default_value [true, false] Returned if the environment variable is not set
    # @return true if the value of the environment variable begins with y or t (case-insensitive)
    def boolean_env_var?(var, default_value: false)
      value = ENV[var.to_s]
      return default_value if value.nil?

      /^(y|t)/i.match? value
    end

    # Return a Float value associated with an environment variable.
    #
    # @param var [#to_s] The name of an environment variable
    # @param default_value [#to_f] Returned if the environment variable is not set
    # @return [Float] the numeric value of the environment variable or the default_value
    def float_env_var(var, default_value: 0)
      value = ENV[var.to_s]
      return default_value.to_f if value.nil?

      value.to_f
    end
  end
end
