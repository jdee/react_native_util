require 'commander'
require_relative 'converter'
require_relative 'metadata'

module ReactNativeUtil
  class CLI
    include Commander::Methods
    include Util

    def run
      program :name, SUMMARY
      program :version, VERSION
      program :description, <<DESC
[Work in progress] Converts a project created with <%= color 'react-native init', BOLD %> to use
CocoaPods with the React pod from node_modules. <%= color '#{NAME} react_pod -h', BOLD %>
for more information.
DESC

      command :react_pod do |c|
        c.syntax = "#{NAME} react_pod [OPTIONS]"
        c.summary = 'Convert a React Native app to use the React pod from node_modules.'
        c.description = <<DESC
[Work in progress] Converts a project created with <%= color 'react-native init', BOLD %> to use
CocoaPods with the React pod from node_modules. This preserves compatibility
with <%= color 'react-native link', BOLD %>. A converted project will still start the Metro packager
automatically via a Run Script build phase in the Xcode project. This is an
alternative to performing manual surgery on a project in Xcode.
DESC

        c.option '--[no-]repo-update', 'Update the local podspec repo (default: update; env. var. REACT_NATIVE_UTIL_REPO_UPDATE)'

        c.action do |_args, opts|
          begin
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
  end
end
