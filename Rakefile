require 'bundler/gem_tasks'

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new

require 'rubocop/rake_task'
RuboCop::RakeTask.new(:rubocop)

require 'yard'
YARD::Rake::YardocTask.new

desc 'Remove all generated files'
task 'clobber:all' => :clobber do
  FileUtils.rm_rf [
    'coverage',
    'doc',
    '.yardoc',
    '_yardoc',
    'test-results'
  ]
end

require_relative 'lib/react_native_util/rake_task'
ReactNativeUtil::RakeTask.new(
  :react_pod,
  'Convert TestApp to use React pod',
  chdir: File.expand_path('examples/TestApp', __dir__)
)

task default: [:spec, :rubocop]
