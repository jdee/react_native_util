# Conversion tools for React Native projects
module ReactNativeUtil
  NAME = 'react_native_util'
  VERSION = '0.5.0'
  SUMMARY = 'Community utility CLI for React Native projects'
  DESCRIPTION = 'Converts a project created with react-native init to use CocoaPods with the ' \
                'React pod from node_modules. This preserves compatibility with ' \
                'react-native link. A converted project will still start the Metro packager ' \
                'automatically via a Run Script build phase in the Xcode project. This is an ' \
                'alternative to performing manual surgery on a project in Xcode.'
end
