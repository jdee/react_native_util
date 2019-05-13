require 'pattern_patch'
require 'rubygems'
require_relative '../lib/react_native_util/metadata'

desc 'Version bump'
task :bump, %i[version] do |_task, opts|
  version = opts[:version]
  if version.nil?
    v = Gem::Version.new ReactNativeUtil::VERSION
    last = v.segments.last
    segments = v.segments[0...-1]
    segments << last + 1
    version = segments.join '.'
  end

  puts "Bumping to v#{version}"

  PatternPatch::Patch.new(
    regexp: /(VERSION = ')[^']+/,
    text: "\\1#{version}",
    mode: :replace
  ).apply 'lib/react_native_util/metadata.rb'

  sh 'git', 'commit', "-qmVersion bump to #{version}", 'lib/react_native_util/metadata.rb'
end
