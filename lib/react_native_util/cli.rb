require 'commander'
require_relative 'converter'

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
        c.syntax = "#{NAME} react_pod [OPTIONS]\n    rn react_pod [OPTIONS]"
        c.summary = 'Convert a React Native app to use the React pod from node_modules.'
        c.description = <<DESC
Converts a React Native Xcode project to use the React pod from node_modules
instead of the projects in the Libraries group. This makes it easier to manage
native dependencies while preserving compatibility with <%= color 'react-native link', BOLD %>.
The command looks for your app's package.json in the current directory and
expects your Xcode project to be located under the ios subdirectory and have
the name specified for your app in package.json. If a Podfile is found in the
ios subdirectory, the conversion will fail.

The React.xcodeproj in the Libraries group of a project created by
<%= color 'react-native init', BOLD %> automatically starts the Metro packager via a Run Script
build phase. When the react_pod command removes the Libraries group from your
app project, it adds an equivalent build phase to your app project so that the
packager will automatically be started when necessary by Xcode.

Use the <%= color '-u', BOLD %> or <%= color '--update', BOLD %> option to update the packager script after
updating React Native, in case the packager script on the React.xcodeproj changes
after it's removed from your project.
DESC

        c.option '-u', '--update', 'Update a previously converted project (default: convert)'
        c.option '--[no-]repo-update', 'Update the local podspec repo (default: update; env. var. REACT_NATIVE_UTIL_REPO_UPDATE)'

        c.examples = {
          'Convert an app project' => 'rn react_pod',
          'Convert an app project without updating the podspec repo' => 'rn react_pod --no-repo-update',
          'Update a converted project' => 'rn react_pod -u'
        }

        c.action do |_args, opts|
          begin
            converter = Converter.new repo_update: opts.repo_update
            if opts.update
              converter.update_project!
            else
              converter.convert_to_react_pod!
            end
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
