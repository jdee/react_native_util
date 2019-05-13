# react_native_util gem

[![Gem](https://img.shields.io/gem/v/react_native_util.svg?style=flat)](https://rubygems.org/gems/react_native_util)
[![Downloads](https://img.shields.io/gem/dt/react_native_util.svg?style=flat)](https://rubygems.org/gems/react_native_util)
[![License](https://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://github.com/jdee/react_native_util/blob/master/LICENSE)
[![CircleCI](https://img.shields.io/circleci/project/github/jdee/react_native_util.svg)](https://circleci.com/gh/jdee/react_native_util)

**Work in progress**

Community utility CLI for React Native projects.

Converts a project created with `react-native init` to use CocoaPods with the
React pod from node_modules. This preserves compatibility with
`react-native link`. A converted project will still start the Metro packager
automatically via a Run Script build phase in the Xcode project. This is an
alternative to performing manual surgery on a project in Xcode.

## Prerequisites

_macOS & Xcode required_

The react_pod command requires `yarn` from Homebrew and the `react-native-cli`.
If installing react_native_util from the Homebrew tap, `yarn` will be
automatically installed if not present. The `react-native-cli` may also be
installed from Homebrew if desired:

```bash
brew install jdee/tap/react_native_util --with-react-native-cli
```

If running from RubyGems, please make sure these packages are installed:
```bash
brew install yarn
```

```bash
npm install -g react-native-cli
```
or
```
brew install react-native-cli
```

## Installation

```bash
[sudo] gem install react_native_util
```

## Install from Homebrew tap

```bash
brew install jdee/tap/react_native_util
```

## Gemfile

```Ruby
gem 'react_native_util'
```

## Usage

```bash
react_native_util -h
rn -h
rn react_pod -h
```

## Try it out

Convert examples/TestApp.

First install dependencies.
```bash
bundle check || bundle install
```

Then use the Rake task
```bash
bundle exec rake react_pod
```

or the CLI.
```bash
cd examples/TestApp
bundle exec rn react_pod
```

Finally see the changes.
```bash
git status
```

_Typical command output:_
```
2019-05-12T15:37:50-07:00 react_native_util react_pod v0.3.0
[✔] yarn install success in 7.2 s
2019-05-12T15:37:57-07:00  Darwin 18.5.0 x86_64
2019-05-12T15:37:57-07:00  Ruby 2.6.3: ~/.rvm/rubies/ruby-2.6.3/bin/ruby
2019-05-12T15:37:57-07:00  RubyGems 3.0.3: ~/.rvm/rubies/ruby-2.6.3/bin/gem
2019-05-12T15:37:57-07:00  Bundler 1.17.2: ~/.rvm/gems/ruby-2.6.3/bin/bundle
2019-05-12T15:37:57-07:00  react-native-cli: /usr/local/bin/react-native
2019-05-12T15:37:57-07:00   react-native-cli: 2.0.1
2019-05-12T15:37:57-07:00   react-native: 0.59.8
2019-05-12T15:37:58-07:00  yarn 1.16.0: /usr/local/bin/yarn
2019-05-12T15:37:58-07:00  cocoapods 1.6.1: ~/.rvm/gems/ruby-2.6.3/bin/pod
2019-05-12T15:37:58-07:00  cocoapods-core: 1.6.1
2019-05-12T15:37:58-07:00 package.json:
2019-05-12T15:37:58-07:00  app name: "TestApp"
2019-05-12T15:37:58-07:00 Found Xcode project at ~/github/jdee/react_native_util/examples/TestApp/ios/TestApp.xcodeproj
2019-05-12T15:37:58-07:00 Dependencies:
2019-05-12T15:37:58-07:00  react-native-webview
2019-05-12T15:37:58-07:00 Unlinking dependencies
[✔] react-native unlink react-native-webview success in 0.6 s
2019-05-12T15:37:59-07:00 Removing Libraries from TestApp
2019-05-12T15:37:59-07:00 Removing Libraries from TestAppTests
2019-05-12T15:37:59-07:00 Removing Libraries group
2019-05-12T15:37:59-07:00 Generating ios/Podfile
2019-05-12T15:37:59-07:00 Linking dependencies
[✔] react-native link react-native-webview success in 0.5 s
2019-05-12T15:37:59-07:00 Generating Pods project and ios/TestApp.xcworkspace
[✔] pod install success in 12.2 s
2019-05-12T15:38:12-07:00 Conversion complete ✅
2019-05-12T15:38:12-07:00 $ open ios/TestApp.xcworkspace
```

## Rake task

Add to Rakefile:
```Ruby
require 'react_native_util/rake'
ReactNativeUtil::Rake::ReactPodTask.new
```

Customize:
```Ruby
require 'react_native_util/rake'
ReactNativeUtil::Rake::ReactPodTask.new(
  :react_pod,                         # task name
  'Convert project to use React pod', # description
  chdir: '/path/to/rn/project',       # path to project package.json
  repo_update: true                   # optionally disable pod repo update
)
```

## Ruby script

```Ruby
require 'react_native_util/converter'

Dir.chdir '/path/to/rn/project' do
  begin
    ReactNativeUtil::Converter.new(repo_update: true).convert_to_react_pod!
  rescue ReactNativeUtil::BaseException => e
    puts "Error from #convert_to_react_pod!: #{e.message}"
  end
end
```

## Documentation

Hosted [Yard](https://yardoc.org) documentation available at
https://www.rubydoc.info/gems/react_native_util.
