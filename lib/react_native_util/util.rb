require 'colored'
require 'tty/spinner'
require_relative 'core_ext/io'
require_relative 'core_ext/regexp'
require_relative 'exceptions'

module ReactNativeUtil
  # Module with utility methods
  module Util
    # [TTY::Platform] Object with platform information
    attr_reader :platform

    # Executes a command with no output to the terminal. A spinner is displayed
    # instead. Output may be directed to a file.
    # @param command Variadic command to be executed
    # @param log [String, Symbol, nil] Output for command (path, IO or a symbol such as :close)
    # @param chdir [String, nil] Directory in which to execute the command
    def run_command_with_spinner(*command, log: nil, chdir: nil)
      STDOUT.flush
      STDERR.flush
      spinner = TTY::Spinner.new "[:spinner] #{command.shelljoin}", format: :flip
      spinner.auto_spin
      execute(*command, log: nil, output: log, chdir: chdir)
      spinner.success '✅'
    rescue ExecutionError => e
      spinner.error e.message
      STDOUT.log "See #{log} for details." if log
      exit(-1)
    end

    # Execute the specified command. If output is non-nil, generate a log
    # at that location. Main log (open) is log.
    #
    # @param command Variadic command to be executed
    # @param chdir [String, nil] Directory in which to execute the command
    # @param output [String, Symbol, IO] Output for command (path, IO or a symbol such as :close)
    # @param log [IO, nil] Open IO for main log (nil to suppress logging command to main log)
    # @return nil
    # @raise ExecutionError If the command fails
    def execute(*command, chdir: nil, output: STDOUT, log: STDOUT)
      log.log_command command unless log.nil?

      options = chdir.nil? ? {} : { chdir: chdir }
      system(*command, options.merge(%i[err out] => output))

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

    # Convenience method to determine if running on a Mac.
    # @return true if running on a Mac
    # @return false otherwise
    def mac?
      @platform ||= TTY::Platform.new
      @platform.mac?
    end

    # Wrapper for STDOUT.log
    # @param message [#to_s] message to log
    def log(message)
      STDOUT.log message
    end
  end
end
