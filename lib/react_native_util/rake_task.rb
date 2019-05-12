require 'rake'
require 'rake/tasklib'
require_relative 'converter'

module ReactNativeUtil
  class RakeTask < Rake::TaskLib
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
          Converter.new(repo_update: repo_update).run
        end
      end
    end
  end
end
