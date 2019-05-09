lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "react_native_convert/metadata"

Gem::Specification.new do |spec|
  spec.name          = ReactNativeConvert::NAME
  spec.version       = ReactNativeConvert::VERSION
  spec.summary       = ReactNativeConvert::SUMMARY
  spec.description   = ReactNativeConvert::DESCRIPTION
  spec.authors       = ['Jimmy Dee']
  spec.email         = ['jgvdthree@gmail.com']
  spec.homepage      = "https://github.com/jdee/#{ReactNativeConvert::NAME}"

  spec.files         = Dir['bin/*', 'lib/**/*'] + %w{README.md LICENSE}
  spec.test_files    = spec.files.grep(/_spec/)

  spec.require_paths = ['lib']
  spec.bindir        = 'bin'
  spec.executables   = [ReactNativeConvert::NAME]

  spec.license       = 'MIT'

  # 2.3 is no longer supported, but it still ships on macOS Mojave.
  # It was also the system Ruby on High Sierra. Otherwise this should
  # be 2.4.
  spec.required_ruby_version = '>= 2.3.0'

  spec.add_dependency 'cocoapods', '~> 1.6' # Also brings in xcodeproj
  spec.add_dependency 'colored', '~> 1.2'
  spec.add_dependency 'commander', '~> 4.4'
  spec.add_dependency 'pattern_patch', '~> 0.5'

  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'pry', '~> 0.12'
  spec.add_development_dependency 'rake', '~> 12.3'
  spec.add_development_dependency 'rspec', '~> 3.8'
  spec.add_development_dependency 'rspec-simplecov', '~> 0.2'
  spec.add_development_dependency 'rspec_junit_formatter', '~> 0.4'
  spec.add_development_dependency 'rubocop', '0.65.0'
  spec.add_development_dependency 'simplecov', '~> 0.16'
  spec.add_development_dependency 'yard', '~> 0.9'
end
