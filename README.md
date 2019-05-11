# react_native_util gem

[![Gem](https://img.shields.io/gem/v/react_native_util.svg?style=flat)](https://rubygems.org/gems/react_native_util)
[![Downloads](https://img.shields.io/gem/dt/react_native_util.svg?style=flat)](https://rubygems.org/gems/react_native_util)
[![License](https://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://github.com/jdee/react_native_util/blob/master/LICENSE)
[![CircleCI](https://img.shields.io/circleci/project/github/jdee/react_native_util.svg)](https://circleci.com/gh/jdee/react_native_util)

**Work in progress**

Community utility CLI for React Native projects.

## Prerequisites

_macOS required_

```bash
brew install yarn # Not necessary if installing from Homebrew tap
npm install -g react-native-cli
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

First set up a test app:
```bash
react-native init TestApp
cd TestApp
yarn add react-native-webview
react-native link react-native-webview
git init .
git add .
git commit -m'Before conversion'
```

Now do the conversion:
```bash
rn react_pod
git status
```

_Typical command output:_
```
2019-05-11T11:07:38-07:00 react_native_util react_pod v0.2.0
2019-05-11T11:07:38-07:00 package.json:
2019-05-11T11:07:38-07:00  app name: "TestApp"
2019-05-11T11:07:38-07:00 Found Xcode project at ~/sandbox/TestApp/ios/TestApp.xcodeproj
2019-05-11T11:07:38-07:00 Installing NPM dependencies with yarn
[✔] yarn success in 0.7 s
2019-05-11T11:07:39-07:00 Dependencies:
2019-05-11T11:07:39-07:00  react-native-webview
2019-05-11T11:07:39-07:00 Unlinking dependencies
[✔] react-native unlink react-native-webview success in 0.5 s
2019-05-11T11:07:40-07:00 Removing Libraries from TestApp
2019-05-11T11:07:40-07:00 Removing Libraries from TestAppTests
2019-05-11T11:07:40-07:00 Removing Libraries group
2019-05-11T11:07:40-07:00 Generating ios/Podfile
2019-05-11T11:07:40-07:00 Linking dependencies
[✔] react-native link react-native-webview success in 0.5 s
2019-05-11T11:07:40-07:00 Generating Pods project and ios/TestApp.xcworkspace
[✔] pod install success in 8.1 s
2019-05-11T11:07:48-07:00 Conversion complete ✅
2019-05-11T11:07:48-07:00 $ open ios/TestApp.xcworkspace
```
