require 'commander'

module ReactNativeConvert
  class CLI
    include Commander::Methods

    def run
      program :name, 'React Native conversion tools'
      program :version, VERSION
      program :description, 'More to come'

      command :react_pod do |c|
        c.syntax = 'react_native_convert react_pod'
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
