require 'rake'
require 'rake/tasklib'
require_relative 'converter'

module ReactNativeUtil
  class RakeTask < Rake::TaskLib
    def initialize(name = :react_pod, chdir: '.', repo_update: boolean_env_var?(:REACT_NATIVE_UTIL_REPO_UPDATE))
      desc 'Convert project to React pod'
      task name do
        Dir.chdir chdir do
          Converter.new(repo_update: repo_update).run
        end
      end
    end
  end
end
