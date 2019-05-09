require 'json'
require 'tty/platform'
require 'xcodeproj'
require_relative 'util'

module ReactNativeConvert
  # Class to perform conversion operations.
  class Converter
    include Util

    # [Array<String>] Default contents of Libraries group
    DEFAULT_DEPENDENCIES = %w[
      RCTAnimation
      React
      RCTActionSheet
      RCTBlob
      RCTGeolocation
      RCTImage
      RCTLinking
      RCTNetwork
      RCTSettings
      RCTText
      RCTVibration
      RCTWebSocket
    ]

    # [Hash] Known subspec requirements for NPM modules
    KNOWN_SUBSPECS = {
      'react-native-webview' => %w[RCTLinkingIOS]
    }

    # [Hash] Contents of ./package.json
    attr_reader :package_json

    # [String] Full path to Xcode project
    attr_reader :xcodeproj_path

    # [Xcodeproj::Project] Contents of the project at xcodproj_path
    attr_reader :xcodeproj

    # Convert project to use React pod
    # @raise ConversionError on failure
    def convert_to_react_pod!
      raise ConversionError, "macOS required." unless mac?

      load_package_json!
      say 'package.json:'
      say " app name: #{package_json['name'].inspect}"

      say 'Installing NPM dependencies with yarn'
      execute 'yarn'

      # 1. Detect project. TODO: Add an option to override.
      @xcodeproj_path = File.expand_path "ios/#{package_json['name']}.xcodeproj"
      load_xcodeproj!
      say "Found Xcode project at #{xcodeproj_path}"

      # 2. Detect native dependencies in Libraries group.
      say 'Dependencies:'
      dependencies.each { |d| say " #{d}" }

      # 3. Run react-native unlink for each one.
      dependencies.each do |dep|
        execute 'react-native', 'unlink', dep
      end

      # 4. Remove Libraries group from Xcode project.
      remove_libraries_group_from_project
      xcodeproj.save

      # 5. Generate boilerplate Podfile.
      # TODO: Determine appropriate subspecs for each

      # 6. Run react-native link for each dependency.

      # 7. pod install

      # 8. SCM/git (add, commit - optional)

      # 9. Open workspace/builds
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

    # Load the project at @xcodeproj_path into @xcodeproj
    # @raise ConversionError on failure
    def load_xcodeproj!
      @xcodeproj = Xcodeproj::Project.open xcodeproj_path
    rescue Errno::ENOENT
      raise ConversionError, "Failed to open #{xcodeproj_path}. File not found."
    rescue Xcodeproj::PlainInformative => e
      raise ConversionError, "Failed to load #{xcodeproj_path}: #{e.message}"
    end

    # A list, usually of PBXFileReferences, of children of the
    # Libraries group from the xcodeproj.
    # @return [Array] an array of child references
    def libraries_group
      @libraries_group ||= xcodeproj['Libraries']
    end

    # Remove the Libraries group from the xcodeproj in memory.
    # Resets @libraries_group to nil as well.
    def remove_libraries_group_from_project
      libraries_group.remove_from_project
      @libraries_group = nil
    end

    # A list of external dependencies from NPM requiring react-native link.
    # @return [Array<String>] a list of NPM package names
    def dependencies
      return @dependencies if @dependencies

      return @dependencies = [] if libraries_group.nil?

      @dependencies = dependency_paths.map do |path|
        # Find the root above the ios/*.xcodeproj under node_modules
        root = File.expand_path '../..', path
        File.basename root
      end
    end

    # Paths to Xcode projects in the Libraries group from external deps.
    # @return [Array<String>] a list of absolute paths to Xcode projects
    def dependency_paths
      return @dependency_paths if @dependency_paths

      return @dependency_paths = [] if libraries_group.nil?

      paths = libraries_group.children.reject { |c| DEFAULT_DEPENDENCIES.include?(c.name.sub(/\.xcodeproj$/, '')) }.map(&:path)

      @dependency_paths = paths.map { |p| File.expand_path p, 'ios' }
    end

    # Required additional subspecs for a dependency
    # @param dep [String] an NPM package name
    # @return [Array<String>] list of subspecs required for the package; may be empty
    def required_subspecs(dep)
      KNOWN_SUBSPECS[dep] || []
    end

    # Additional subspecs required for all external dependencies.
    # @return [Array<String>] list of subspecs required for all external dependencies; may be empty
    def additional_subspecs
      dependencies.inject([]) do |spex, dep|
        (spex + required_subspecs(dep)).compact # remove dupes
      end
    end
  end
end
