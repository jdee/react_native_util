require 'rake'
require 'rake/tasklib'
require_relative '../converter'

module ReactNativeUtil
  module Rake
    # Rakefile:
    #   require 'react_native_util/rake'
    #   ReactNativeUtil::Rake::ReactPodTask.new chdir: '/path/to/rn/app'
    class ReactPodTask < ::Rake::TaskLib
      include Util
      def initialize(
        name = :react_pod,
        description = 'Convert project to use React pod',
        chdir: '.',
        repo_update: boolean_env_var?(:REACT_NATIVE_UTIL_REPO_UPDATE)
      )
        desc description
        task name do
          Dir.chdir chdir do
            Converter.new(repo_update: repo_update).convert_to_react_pod!
          end
        end
      end
    end
  end
end
