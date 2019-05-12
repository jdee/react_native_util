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

    def validate_yarn!
      return if have_command?(:yarn)

      unless have_command?(:brew)
        raise ConversionError, 'yarn command not found, and brew command not available to install yarn. Please install yarn to continue. https://yarnpkg.com'
      end

      answer = ask 'yarn command not found. Install from Homebrew? [Y/n]', nil
      raise ConversionError, 'yarn command not found. Please install yarn to continue. https://yarnpkg.com' unless answer

      run_command_with_spinner! 'brew', 'install', 'yarn', log: File.join(Dir.tmpdir, 'brew-install-yarn.log')
    end

    def validate_react_native_cli!
    end
  end
end
