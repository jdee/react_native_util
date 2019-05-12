require 'colored'
require 'tmpdir'
require 'tty/platform'
require 'tty/spinner'
require_relative 'core_ext/io'
require_relative 'core_ext/regexp'
require_relative 'exceptions'

module ReactNativeUtil
  # Module with utility methods
  module Util
    # Executes a command with no output to the terminal. A spinner is displayed
    # instead. Output may be directed to a file.
    # @param command Variadic command to be executed
    # @param log [String, Symbol, nil] Output for command (path, IO or a symbol such as :close)
    # @param chdir [String, nil] Directory in which to execute the command
    # @raise ExecutionError on failure
    def run_command_with_spinner!(*command, log: nil, chdir: nil)
      STDOUT.flush
      STDERR.flush
      spinner = TTY::Spinner.new "[:spinner] #{command.shelljoin}", format: :flip
      spinner.auto_spin
      start_time = Time.now
      execute(*command, log: nil, output: log, chdir: chdir)
      elapsed = Time.now - start_time
      spinner.success "success in #{format('%.1f', elapsed)} s"
    rescue ExecutionError
      elapsed = Time.now - start_time
      spinner.error "failure in #{format('%.1f', elapsed)} s"
      STDOUT.log "See #{log} for details." if log && log.kind_of?(String)
      raise
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

      raise ExecutionError, "#{command.shelljoin}: #{$?}" unless $?.success?

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

    # [TTY::Platform] Object with platform information
    def platform
      @platform ||= TTY::Platform.new
    end

    # Convenience method to determine if running on a Mac.
    # @return true if running on a Mac
    # @return false otherwise
    def mac?
      platform.mac?
    end

    # Wrapper for STDOUT.log
    # @param message [#to_s] message to log
    def log(message)
      STDOUT.log message
    end

    # Determine if a specific command is available.
    #
    # @param command [#to_s] A command to check for
    # @return true if found, false otherwise
    def have_command?(command)
      # May be shell-dependent, OS-dependent
      # Kernel#system does not raise Errno::ENOENT when running under the Bundler
      !`which #{command}`.empty?
    end

    # Validate one or more commands. If the specified command is not
    # available in the PATH (via which), a ConversionError is raised noting
    # the package to be installed (from Homebrew, e.g.).
    #
    # When package names to be installed differ from command names, a Hash
    # may be used. For example:
    #    validate_commands! [:yarn, 'react-native' => 'react-native-cli']
    #
    # @param commands [Array, Hash, #to_s] one or more commands to be validated.
    # @raise ConversionError if any command not found
    def validate_commands!(commands)
      errors = []

      case commands
      when Array
        # Validate each command in the array, accumulating error messages
        # if necessary.
        commands.each do |c|
          begin
            validate_commands! c
          rescue ConversionError => e
            errors += e.message.split("\n")
          end
        end
      when Hash
        # Each key represents a command to check. The value is the package to
        # install if missing.
        commands.each do |key, value|
          next if have_command?(key)

          errors << "#{key} command not found. Please install #{value} to continue."
        end
      else
        # commands is a single command to be validated. The package name is the
        # same. Usually a symbol or a string, but only has to respond to #to_s.
        errors << "#{commands} command not found. Please install #{commands} to continue." unless have_command? commands
      end

      return if errors.empty?

      raise ConversionError, errors.join("\n")
    end
  end
end
