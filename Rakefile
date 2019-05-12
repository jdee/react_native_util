require 'bundler/gem_tasks'

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new

require 'rubocop/rake_task'
RuboCop::RakeTask.new(:rubocop)

require 'yard'
YARD::Rake::YardocTask.new

desc 'Remove files generated by react_pod task'
task 'clobber:examples' do
  FileUtils.rm_rf [
    'examples/TestApp/ios/Podfile',
    'examples/TestApp/ios/Podfile.lock',
    'examples/TestApp/ios/Pods',
    'examples/TestApp/ios/TestApp.xcworkspace',
    'examples/TestApp/node_modules'
  ]
end

desc 'Remove all generated files'
task 'clobber:all' => [:clobber, 'clobber:examples'] do
  FileUtils.rm_rf [
    'coverage',
    'doc',
    '.yardoc',
    '_yardoc',
    'test-results'
  ]
end

require_relative 'lib/react_native_util/rake/react_pod_task'
ReactNativeUtil::Rake::ReactPodTask.new(
  :react_pod,
  'Convert TestApp to use React pod',
  chdir: File.expand_path('examples/TestApp', __dir__)
)

task default: [:spec, :rubocop]
