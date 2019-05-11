require 'cocoapods-core'
require 'commander'
require 'rubygems'
require_relative 'converter'
require_relative 'metadata'

module ReactNativeUtil
  class CLI
    include Commander::Methods
    include Util

    def run
      program :name, SUMMARY
      program :version, VERSION
      program :description, DESCRIPTION

      command :react_pod do |c|
        c.syntax = "#{NAME} react_pod [OPTIONS]"
        c.summary = 'Convert a React Native app to use the React pod from node_modules.'
        c.description = "[Work in progress] Removes all static libraries built by the Libraries group and adds a generic " \
          "Podfile.\nResults in a buildable, working project."

        c.option '--[no-]repo-update', 'Update the local podspec repo (default: update; env. var. REACT_NATIVE_UTIL_REPO_UPDATE)'

        c.action do |_args, opts|
          begin
            report_configuration
            converter = Converter.new repo_update: opts.repo_update
            converter.convert_to_react_pod!
            exit 0
          rescue ExecutionError => e
            # Generic command failure.
            log e.message.red.bold
            exit(-1)
          rescue ConversionError => e
            log "Conversion failed: #{e.message}".red.bold
            exit(-1)
          end
        end
      end

      run!
    end

    def report_configuration
      log "#{NAME} react_pod v#{VERSION}".bold

      log ' Installed from Homebrew' if ENV['REACT_NATIVE_UTIL_INSTALLED_FROM_HOMEBREW']

      log " #{`uname -msr`}"

      log " Ruby #{RUBY_VERSION}: #{RbConfig.ruby}"
      log " RubyGems #{Gem::VERSION}: #{`which gem`}"
      log " Bundler #{Bundler::VERSION}: #{`which bundle`}" if defined?(Bundler)

      log_command_path 'react-native', 'react-native-cli', include_version: false
      unless `which react-native`.empty?
        react_native_info = `react-native --version`
        react_native_info.split("\n").each { |l| log "  #{l}" }
      end

      log_command_path 'yarn'
      log_command_path 'pod', 'cocoapods'

      log " cocoapods-core: #{Pod::CORE_VERSION}"
    rescue Errno::ENOENT
      # On Windows, e.g., which and uname may not work.
      log 'Conversion failed: macOS required.'.red.bold
      exit(-1)
    end

    def log_command_path(command, package = command, include_version: true)
      path = `which #{command}`
      if path.empty?
        log " #{package}: #{'not found'.red.bold}"
        return
      end

      if include_version
        version = `#{command} --version`.chomp
        log " #{package} #{version}: #{path}"
      else
        log " #{package}: #{path}"
      end
    end
  end
end
