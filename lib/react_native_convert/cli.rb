require 'commander'
require_relative 'converter'
require_relative 'metadata'

module ReactNativeConvert
  class CLI
    include Commander::Methods
    include Util

    def run
      program :name, SUMMARY
      program :version, VERSION
      program :description, DESCRIPTION

      command :react_pod do |c|
        c.syntax = "#{NAME} react_pod"
        c.summary = 'Convert a React Native app to use the React pod from node_modules.'
        c.description = 'More to come'

        c.option '--[no-]repo-update', 'Update the local podspec repo (default: update; env. var. REACT_NATIVE_CONVERT_REPO_UPDATE)'

        c.action do |_args, opts|
          begin
            converter = Converter.new repo_update: opts.repo_update
            converter.convert_to_react_pod!
          rescue ConversionError => e
            log "Conversion failed: #{e.message}"
          end
        end
      end

      run!
    end
  end
end
