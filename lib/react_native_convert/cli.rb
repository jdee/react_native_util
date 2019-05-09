require 'commander'

module ReactNativeConvert
  class CLI
    include Commander::Methods

    def run
      program :name, SUMMARY
      program :version, VERSION
      program :description, DESCRIPTION

      command :react_pod do |c|
        c.syntax = "#{NAME} react_pod"
        c.summary = 'Convert a React Native app to use the React pod from node_modules.'
        c.description = 'More to come'

        c.action do
          Converter.new.convert_to_react_pod
        end
      end

      run!
    end
  end
end
