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

Include react-native-cli from Homebrew:
```bash
brew install jdee/tap/react_native_util --with-react-native-cli
```

## Gemfile

```Ruby
gem 'react_native_util'
```

## Fastlane

See https://github.com/jdee/fastlane-plugin-react_native_util
```bash
fastlane add_plugin react_native_util
```

## Usage

```bash
react_native_util -h
rn -h
rn react_pod -h
```

## react_pod command

Converts a React Native Xcode project to use the React pod from node_modules
instead of the projects in the Libraries group. This makes it easier to manage
native dependencies while preserving compatibility with `react-native link`.
The command looks for your app's package.json in the current directory and
expects your Xcode project to be located under the ios subdirectory and have
the name specified for your app in package.json. If a Podfile is found in the
ios subdirectory, the conversion will fail.

The React.xcodeproj in the Libraries group of a project created by
`react-native init` automatically starts the Metro packager via a Run Script
build phase. When the react_pod command removes the Libraries group from your
app project, it adds an equivalent build phase to your app project so that the
packager will automatically be started when necessary by Xcode.

Use the `-u` or `--update` option to update the packager script after
updating React Native, in case the packager script on the React.xcodeproj changes
after it's removed from your project.

### Options

|option|description|env. var.|
|------|-----------|---------|
|-h, --help|Print command help||
|-t, --trace|Print a stack trace in case of error||
|-u, --update|Update a previously converted project||
|--[no-]repo-update|Don't update the local podspec repo|REACT_NATIVE_UTIL_REPO_UPDATE|

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
2019-05-15T12:04:44-07:00 react_native_util react_pod v0.5.2
2019-05-15T12:04:46-07:00  Darwin 18.5.0 x86_64
2019-05-15T12:04:46-07:00  Ruby 2.6.3: ~/.rvm/rubies/ruby-2.6.3/bin/ruby
2019-05-15T12:04:46-07:00  RubyGems 3.0.3: ~/.rvm/rubies/ruby-2.6.3/bin/gem
2019-05-15T12:04:46-07:00  Bundler 2.0.1: ~/.rvm/gems/ruby-2.6.3/bin/bundle
2019-05-15T12:04:46-07:00  react-native-cli: ~/.nvm/versions/node/v10.15.0/bin/react-native
2019-05-15T12:04:46-07:00   react-native-cli: 2.0.1
2019-05-15T12:04:46-07:00   react-native: 0.59.8
2019-05-15T12:04:46-07:00  yarn 1.16.0: /usr/local/bin/yarn
2019-05-15T12:04:47-07:00  cocoapods 1.6.1: ~/.rvm/gems/ruby-2.6.3/bin/pod
2019-05-15T12:04:47-07:00  cocoapods-core: 1.6.1
2019-05-15T12:04:47-07:00 package.json:
2019-05-15T12:04:47-07:00  app name: "TestApp"
2019-05-15T12:04:47-07:00 Found Xcode project at ~/github/$USER/react_native_util/examples/TestApp/ios/TestApp.xcodeproj
2019-05-15T12:04:47-07:00 Dependencies:
2019-05-15T12:04:47-07:00  react-native-webview
2019-05-15T12:04:47-07:00 Unlinking dependencies
[✔] react-native unlink react-native-webview success in 0.5 s
2019-05-15T12:04:47-07:00 Generating ios/Podfile
2019-05-15T12:04:47-07:00 Removing Libraries from TestApp
2019-05-15T12:04:47-07:00  Removing libRCTBlob.a
2019-05-15T12:04:47-07:00  Removing libRCTAnimation.a
2019-05-15T12:04:47-07:00  Removing libReact.a
2019-05-15T12:04:47-07:00  Removing libRCTActionSheet.a
2019-05-15T12:04:47-07:00  Removing libRCTGeolocation.a
2019-05-15T12:04:47-07:00  Removing libRCTImage.a
2019-05-15T12:04:47-07:00  Removing libRCTLinking.a
2019-05-15T12:04:47-07:00  Removing libRCTNetwork.a
2019-05-15T12:04:47-07:00  Removing libRCTSettings.a
2019-05-15T12:04:47-07:00  Removing libRCTText.a
2019-05-15T12:04:47-07:00  Removing libRCTVibration.a
2019-05-15T12:04:47-07:00  Removing libRCTWebSocket.a
2019-05-15T12:04:47-07:00 Removing Libraries from TestAppTests
2019-05-15T12:04:47-07:00  Removing libReact.a
2019-05-15T12:04:47-07:00 Removing Libraries group
2019-05-15T12:04:47-07:00 Linking dependencies
[✔] react-native link react-native-webview success in 0.6 s
2019-05-15T12:04:48-07:00 Generating Pods project and ios/TestApp.xcworkspace
2019-05-15T12:04:48-07:00 Once pod install is complete, your project will be part of this workspace.
2019-05-15T12:04:48-07:00 From now on, you should build the workspace with Xcode instead of the project.
2019-05-15T12:04:48-07:00 Always add the workspace and Podfile.lock to SCM.
2019-05-15T12:04:48-07:00 It is common practice also to add the Pods directory.
2019-05-15T12:04:48-07:00 The workspace will be automatically opened when pod install completes.
[✔] pod install success in 9.2 s
2019-05-15T12:04:57-07:00 Conversion complete ✅
2019-05-15T12:04:57-07:00 $ open ios/TestApp.xcworkspace
```

## Convert your own app with Rake

From this repo:

```bash
bundle exec rake react_pod[/path/to/your/app]
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
  'Update project',                   # description for :update task
  chdir: '/path/to/rn/project',       # path to project package.json
  repo_update: true                   # optionally disable pod repo update
)
```

Override `chdir` at the command line:
```bash
rake react_pod[/path/to/another/rn/project]
```

Convert project:
```bash
rake react_pod
```

Update converted project:
```bash
rake react_pod:update
```

## Ruby script

```Ruby
require 'react_native_util/converter'

Dir.chdir '/path/to/rn/project' do
  begin
    converter = ReactNativeUtil::Converter.new(repo_update: true)

    # Convert a project to use the React pod
    converter.convert_to_react_pod!

    # Update a converted project
    converter.update_project!
  rescue ReactNativeUtil::BaseException => e
    puts "Error from ReactNativeUtil::Converter: #{e.message}"
  end
end
```

## Documentation

Hosted [Yard](https://yardoc.org) documentation available at
https://www.rubydoc.info/gems/react_native_util.

## Successfully converted apps:

- https://github.com/azhavrid/movie-swiper
