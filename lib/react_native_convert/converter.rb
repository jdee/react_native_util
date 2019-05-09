require 'json'
require 'xcodeproj'
require_relative 'util'

module ReactNativeConvert
  class Converter
    include Util

    attr_reader :package_json
    attr_reader :xcodeproj_path
    attr_reader :xcodeproj

    # Convert project to use React pod
    # @raise ConversionError on failure
    def convert_to_react_pod!
      begin
        @package_json = File.open('package.json') { |f| JSON.parse f.read }
      rescue Errno::ENOENT
        raise ConversionError, 'Failed to load package.json. File not found. Please run from the project root.'
      rescue JSON::ParserError => e
        raise ConversionError, "Failed to parse package.json: #{e.message}"
      end

      say 'package.json:'
      say " app name: #{package_json['name'].inspect}"

      # 1. Detect project. TODO: Add an option to override.
      @xcodeproj_path = File.expand_path "ios/#{package_json['name']}.xcodeproj"
      begin
        @xcodeproj = Xcodeproj::Project.open xcodeproj_path
      rescue Errno::ENOENT
        raise ConversionError, "Failed to open #{xcodeproj_path}. File not found."
      rescue Xcodeproj::PlainInformative => e
        raise ConversionError, "Failed to load #{xcodeproj_path}: #{e.message}"
      end

      say "Found Xcode project at #{xcodeproj_path}"

      # 2. Detect native dependencies in Libraries group.

      # 3. Run react-native unlink for each one.

      # 4. Remove Libraries group from Xcode project.

      # 5. Generate boilerplate Podfile.
      # TODO: Determine appropriate subspecs for each

      # 6. Run react-native link for each dependency.

      # 7. pod install

      # 8. SCM/git (add, commit - optional)

      # 9. Open workspace/builds
    end
  end
end
