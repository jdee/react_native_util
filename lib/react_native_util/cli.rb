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
      program :description, DESCRIPTION

      command :react_pod do |c|
        c.syntax = "#{NAME} react_pod [OPTIONS]"
        c.summary = 'Convert a React Native app to use the React pod from node_modules.'
        c.description = "[Work in progress] Removes all static libraries built by the Libraries group and adds a generic " \
          "Podfile.\nResults in a buildable, working project."

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
