# react_native_util gem

[![License](https://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://github.com/jdee/react_native_util/blob/master/LICENSE)
[![CircleCI](https://img.shields.io/circleci/project/github/jdee/react_native_util.svg)](https://circleci.com/gh/jdee/react_native_util)

**Work in progress**

Conversion tools for React Native projects.

```bash
git clone https://github.com/jdee/react_native_util
cd react_native_util
bundle check || bundle install
[sudo] bundle exec rake install:local
react_native_util -h
```

## Gemfile

```Ruby
gem 'react_native_util', git: 'https://github.com/jdee/react_native_util'
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
react_native_util react_pod
git status
```
