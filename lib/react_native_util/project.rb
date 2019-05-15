require 'pathname'

require_relative 'core_ext/xcodeproj'
require_relative 'util'

module ReactNativeUtil
  class Project < Xcodeproj::Project
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

    attr_accessor :app_name

    def app_target(platform = :ios)
      targets.find { |t| t.platform_name == platform && t.product_type == 'com.apple.product-type.application' }
    end

    def test_target(platform = :ios)
      targets.select(&:test_target_type?).select { |t| t.platform_name == platform }.first
    end

    # Validate an assumption about the project. TODO: Provide override option.
    # @raise ConversionError if an application target is not found with the same name as the project.
    def validate_app_target!
      raise ConversionError, "Unable to find application target in #{path}." if app_target.nil?
    end

    # A representation of the Libraries group (if any) from the Xcode project.
    # @return the Libraries group
    def libraries_group
      self['Libraries']
    end

    # Remove the Libraries group from the xcodeproj in memory.
    def remove_libraries_group
      # Remove links against these static libraries
      targets.select { |t| t.platform_name == :ios }.each do |t|
        remove_libraries_from_target t
      end

      # unless (library_roots - DEFAULT_DEPENDENCIES).empty?
      #   log 'Libraries group not empty. Not removing.'
      #   return
      # end

      # log 'Removing Libraries group'
      # libraries_group.remove_from_project
    end

    def remove_libraries_from_target(target)
      to_remove = target.frameworks_build_phase.files.select do |file|
        path = file.file_ref.pretty_print
        next false unless /^lib(.+)\.a$/.match?(path)

        if target.platform_name == :tvos
          path = path.sub(/-tvOS\.a$/, '.a')
        end

        static_libs.include?(path)
      end

      log "Removing Libraries from #{target.name}" unless to_remove.empty?
      to_remove.each do |f|
        log " Removing #{f.file_ref.pretty_print}"
        target.frameworks_build_phase.remove_build_file f
      end
    end

    # A list of external dependencies from NPM requiring react-native link.
    # @return [Array<String>] a list of NPM package names
    def dependencies
      return [] if libraries_group.nil?

      dependency_paths.map do |path|
        # Map each path to a Pathname, expanding $(SRCROOT) or ${SRCROOT}
        # SRCROOT = location of the app project: ./ios
        Pathname.new path.gsub(/\$(\(SRCROOT\)|{SRCROOT})/, 'ios')
      end.select do |pathname|
        # Valid if any path component named node_modules
        pathname.each_filename do |path_component|
          break true if path_component == 'node_modules'

          false
        end
      end.map do |pathname|
        # Map each selected Pathname to the root immediately under node_modules
        node_modules_found = false
        pathname.each_filename do |path_component|
          break path_component if node_modules_found

          node_modules_found = path_component == 'node_modules'
          '' # In case node_modules is the last component
          # TODO: Then what? Shouldn't happen, of course....
        end
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

    # Adds the Start Packager script from the React.xcodeproj under node_modules
    # to the main application target before deleting React.xcodeproj from the
    # Libraries group. Adjusts paths in the script to account for the different
    # project location. If the relevant build phase is not found, a warning is
    # logged, and this step is skipped.
    def add_packager_script_from(react_project)
      old_packager_phase = react_project.packager_phase
      unless old_packager_phase
        log 'Could not find packager build phase in React.xcodeproj. Skipping.'.yellow
        return
      end

      # location of project is different relative to packager script
      script = old_packager_phase.shell_script.gsub(%r{../scripts}, '../node_modules/react-native/scripts')

      phase = app_target.new_shell_script_build_phase old_packager_phase.name
      phase.shell_script = script

      # Move packager script to first position. This is independent of the
      # entire Xcode build process. As an optimization, the packager can
      # load its dependencies in parallel. This is the way it is on the
      # original React.xcodeproj.
      app_target.build_phases.delete phase
      app_target.build_phases.insert 0, phase
    end

    # All static libraries from the Libraries group
    # @return [Array<String>] an array of filenames
    def static_libs(platform = :ios)
      library_roots.map do |root|
        case platform
        when :tvos
          "lib#{root}-tvOS.a"
        else
          "lib#{root}.a"
        end
      end
    end

    # Returns the original Start Packager build phase (from the React.xcodeproj
    # under node_modules). This contains the original script.
    # @return the packager build phase if found
    # @return nil if not found
    def packager_phase
      targets.first.build_phases.find { |p| p.name =~ /packager/i }
    end
  end
end
