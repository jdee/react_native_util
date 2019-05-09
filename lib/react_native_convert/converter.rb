require_relative 'util'

module ReactNativeConvert
  class Converter
    include Util

    def convert_to_react_pod
      # 1. Detect native dependencies in Libraries group.

      # 2. Run react-native unlink for each one.

      # 3. Remove Libraries group from Xcode project.

      # 4. Generate boilerplate Podfile.
      # TODO: Determine appropriate subspecs for each

      # 5. Run react-native link for each dependency.

      # 6. pod install

      # 7. SCM/git (add, commit - optional)

      # 8. Open workspace/builds
    end
  end
end
