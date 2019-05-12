require 'cocoapods-core'
require 'erb'
require 'json'
require 'rubygems'
require 'tmpdir'
require 'tty/platform'
require 'xcodeproj'
require_relative 'util'

module ReactNativeUtil
  # Class to perform conversion operations.
  class Converter
    include Util

    # [Array<String>] Xcode projects from react-native that may be in the Libraries group
    DEFAULT_DEPENDENCIES = %w[
      ART
      React
      RCTActionSheet
      RCTAnimation
      RCTBlob
      RCTCameraRoll
      RCTGeolocation
      RCTImage
      RCTLinking
      RCTNetwork
      RCTPushNotification
      RCTSettings
      RCTTest
      RCTText
      RCTVibration
      RCTWebSocket
    ]

    # [String] Path to the Podfile template
    PODFILE_TEMPLATE_PATH = File.expand_path '../assets/templates/Podfile.erb', __dir__

    # [Hash] Contents of ./package.json
    attr_reader :package_json

    # [String] Full path to Xcode project
    attr_reader :xcodeproj_path

    # [Xcodeproj::Project] Contents of the project at xcodproj_path
    attr_reader :xcodeproj

    attr_reader :options
    attr_reader :react_podspec

    def initialize(repo_update: nil)
      @options = {}
      if repo_update.nil?
        @options[:repo_update] = boolean_env_var?(:REACT_NATIVE_UTIL_REPO_UPDATE, default_value: true)
      else
        @options[:repo_update] = repo_update
      end
    end

    # Convert project to use React pod
    # @raise ConversionError on failure
    def convert_to_react_pod!
      # Make sure no uncommitted changes
      check_repo_status!

      report_configuration!

      raise ConversionError, "macOS required." unless mac?

      load_package_json!
      log 'package.json:'
      log " app name: #{app_name.inspect}"

      # 1. Detect project. TODO: Add an option to override.
      @xcodeproj_path = File.expand_path "ios/#{app_name}.xcodeproj"
      load_xcodeproj!
      log "Found Xcode project at #{xcodeproj_path}"

      if libraries_group.nil?
        log "Libraries group not found in #{xcodeproj_path}. No conversion necessary."
        exit 0
      end

      if File.exist? podfile_path
        log "Podfile already present at #{File.expand_path podfile_path}.".red.bold
        log "A future release of #{NAME} may support integration with an existing Podfile."
        log 'This release can only convert apps that do not currently use a Podfile.'
        exit 1
      end

      load_react_podspec!

      # 2. Detect native dependencies in Libraries group.
      log 'Dependencies:'
      dependencies.each { |d| log " #{d}" }

      # Save for after Libraries removed.
      deps_to_add = dependencies

      # 3. Run react-native unlink for each one.
      log 'Unlinking dependencies'
      dependencies.each do |dep|
        run_command_with_spinner! 'react-native', 'unlink', dep, log: File.join(Dir.tmpdir, "react-native-unlink-#{dep}.log")
      end

      # reload after react-native unlink
      load_xcodeproj!

      # 4a. Add Start Packager script
      validate_app_target!
      add_packager_script

      # Make a note of pod subspecs to replace Libraries group
      load_subspecs_from_libraries

      # 4b. Remove Libraries group from Xcode project.
      remove_libraries_group_from_project!

      xcodeproj.save

      # 5. Generate boilerplate Podfile.
      generate_podfile!

      # 6. Run react-native link for each dependency.
      log 'Linking dependencies'
      deps_to_add.each do |dep|
        run_command_with_spinner! 'react-native', 'link', dep, log: File.join(Dir.tmpdir, "react-native-link-#{dep}.log")
      end

      # 7. pod install
      log "Generating Pods project and ios/#{app_name}.xcworkspace"
      command = %w[pod install]
      command << '--repo-update' if options[:repo_update]
      run_command_with_spinner!(*command, chdir: 'ios', log: File.join(Dir.tmpdir, 'pod-install.log'))

      log 'Conversion complete ✅'

      # 8. SCM/git (add, commit - optional)

      # 9. Open workspace/build
      execute 'open', File.join('ios', "#{app_name}.xcworkspace")
    end

    # Read the contents of ./package.json into @package_json
    # @raise ConversionError on failure
    def load_package_json!
      @package_json = File.open('package.json') { |f| JSON.parse f.read }
    rescue Errno::ENOENT
      raise ConversionError, 'Failed to load package.json. File not found. Please run from the project root.'
    rescue JSON::ParserError => e
      raise ConversionError, "Failed to parse package.json: #{e.message}"
    end

    def install_npm_deps_if_needed!
      raise ConversionError, 'package.json not found. Please run from the project root.' unless File.readable?('package.json')

      execute 'yarn', 'check', '--integrity', log: nil, output: :close
      execute 'yarn', 'check', '--verify-tree', log: nil, output: :close
    rescue ExecutionError
      # install deps if either check fails
      run_command_with_spinner! 'yarn', 'install', log: File.join(Dir.tmpdir, 'yarn.log')
    end

    def report_configuration!
      log "#{NAME} react_pod v#{VERSION}".bold

      install_npm_deps_if_needed!

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

    # Load the project at @xcodeproj_path into @xcodeproj
    # @raise ConversionError on failure
    def load_xcodeproj!
      @xcodeproj = nil # in case of exception on reopen
      @xcodeproj = Xcodeproj::Project.open xcodeproj_path
    rescue Errno::ENOENT
      raise ConversionError, "Failed to open #{xcodeproj_path}. File not found."
    rescue Xcodeproj::PlainInformative => e
      raise ConversionError, "Failed to load #{xcodeproj_path}: #{e.message}"
    end

    def load_react_podspec!
      podspec_dir = 'node_modules/react-native'
      podspec_contents = File.read "#{podspec_dir}/React.podspec"
      podspec_contents.gsub!(/__dir__/, podspec_dir.inspect)

      require 'cocoapods-core'
      # rubocop: disable Security/Eval
      @react_podspec = eval(podspec_contents)
      # rubocop: enable Security/Eval
    end

    # A representation of the Libraries group (if any) from the Xcode project.
    # @return the Libraries group
    def libraries_group
      xcodeproj['Libraries']
    end

    # Remove the Libraries group from the xcodeproj in memory.
    # Resets @libraries_group to nil as well.
    def remove_libraries_group_from_project!
      # Remove links against these static libraries
      xcodeproj.targets.reject { |t| t.name =~ /-tvOS/ }.each do |t|
        remove_libraries_from_target t
      end

      log 'Removing Libraries group'
      libraries_group.remove_from_project
    end

    def remove_libraries_from_target(target)
      log "Removing Libraries from #{target.name}"
      to_remove = target.frameworks_build_phase.files.select do |file|
        path = file.file_ref.pretty_print
        next false unless /^lib(.+)\.a$/.match?(path)

        static_libs.include?(path)
      end

      to_remove.each { |f| target.frameworks_build_phase.remove_build_file f }
    end

    # A list of external dependencies from NPM requiring react-native link.
    # @return [Array<String>] a list of NPM package names
    def dependencies
      return [] if libraries_group.nil?

      dependency_paths.map do |path|
        # Find the root above the ios/*.xcodeproj under node_modules
        root = File.expand_path '../..', path
        File.basename root
      end
    end

    # Paths to Xcode projects in the Libraries group from external deps.
    # @return [Array<String>] a list of absolute paths to Xcode projects
    def dependency_paths
      return [] if libraries_group.nil?

      paths = libraries_group.children.reject { |c| DEFAULT_DEPENDENCIES.include?(c.name.sub(/\.xcodeproj$/, '')) }.map(&:path)
      paths.map { |p| File.expand_path p, File.join(Dir.pwd, 'ios') }
    end

    def library_roots
      libraries_group.children.map do |library|
        File.basename(library.path).sub(/\.xcodeproj$/, '')
      end
    end

    # All static libraries from the Libraries group
    # @return [Array<String>] an array of filenames
    def static_libs
      library_roots.map { |root| "lib#{root}.a" }
    end

    def load_subspecs_from_libraries
      roots = library_roots - %w[React]
      @subspecs_from_libraries = roots.select { |r| DEFAULT_DEPENDENCIES.include?(r) }.map do |root|
        case root
        when 'RCTLinking'
          'RCTLinkingIOS'
        else
          root
        end
      end
    end

    # The name of the app as specified in package.json
    # @return [String] the app name
    def app_name
      @app_name ||= package_json['name']
    end

    def app_target
      xcodeproj.targets.find { |t| t.name == app_name }
    end

    def test_target
      xcodeproj.targets.select(&:test_target_type?).reject { |t| t.name =~ /tvOS/ }.first
    end

    # Validate an assumption about the project. TODO: Provide override option.
    # @raise ConversionError if an application target is not found with the same name as the project.
    def validate_app_target!
      raise ConversionError, "Unable to find target #{app_name} in #{xcodeproj_path}." if app_target.nil?
      raise ConversionError, "Target #{app_name} is not an application target." unless app_target.product_type == 'com.apple.product-type.application'
    end

    def podfile_path
      'ios/Podfile'
    end

    # Generate a Podfile from a template.
    def generate_podfile!
      log "Generating #{podfile_path}"
      podfile_contents = ERB.new(File.read(PODFILE_TEMPLATE_PATH)).result binding
      File.open podfile_path, 'w' do |file|
        file.write podfile_contents
      end
    end

    def check_repo_status!
      # If the git command is not installed, there's not much we can do.
      # Don't want to use verify_git here, which will insist on installing
      # the command. The logic of that method could change.
      return if `which git`.empty?

      unless Dir.exist? ".git"
        `git rev-parse --git-dir > /dev/null 2>&1`
        # Not a git repo
        return unless $?.success?
      end

      `git diff-index --quiet HEAD --`
      return if $?.success?

      raise ConversionError, 'Uncommitted changes in repo. Please commit or stash before continuing.'
    end

    # Adds the Start Packager script from the React.xcodeproj under node_modules
    # to the main application target before deleting React.xcodeproj from the
    # Libraries group. Adjusts paths in the script to account for the different
    # project location. If React.xcodeproj cannot be opened, or if the relevant
    # build phase is not found, a warning is logged, and this step is skipped.
    #
    # TODO: The build phase is added after all other build phases. Ideally it
    # can be moved to the beginning. The packager is independent of the Xcode
    # build process. It may be started at any time. Starting it early is an
    # optimization that allows it to load while the build is in progress.
    # Currently it's possible to simply drag the build phase in Xcode to a
    # higher position after running the react_pod command.
    def add_packager_script
      old_packager_phase = packager_phase_from_react_project
      unless old_packager_phase
        log 'Could not find packager build phase in React.xcodeproj. Skipping.'.yellow
        return
      end

      # location of project is different relative to packager script
      script = old_packager_phase.shell_script.gsub(%r{../scripts}, '../node_modules/react-native/scripts')

      phase = app_target.new_shell_script_build_phase old_packager_phase.name
      phase.shell_script = script
    end

    # Returns a Project object with the contents of the React.xcodeproj project
    # from node_modules.
    # @return [Xcodeproj::Project] a Project object with the contents of React.xcodeproj from node_modules
    # @raise Xcodeproj::PlainInformative in case of most failures
    def react_project!
      return @react_project if @react_project

      path = libraries_group.children.find { |c| c.path =~ /React.xcodeproj/ }.real_path
      @react_project = Xcodeproj::Project.open path
    end

    # Returns the original Start Packager build phase from the React.xcodeproj
    # under node_modules. This contains the original script.
    # @return the packager build phase if found
    # @return nil if not found or React.xcodeproj cannot be opened
    def packager_phase_from_react_project
      react_project!.targets.first.build_phases.find { |p| p.name =~ /packager/i }
    rescue Errno::ENOENT
      log 'Could not open React.xcodeproj. File not found.'
      nil
    rescue Xcodeproj::PlainInformative => e
      log "Could not open React.xcodeproj. #{e.message}"
      nil
    end
  end
end
