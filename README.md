# react_native_convert gem

[![License](https://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://github.com/jdee/react_native_convert/blob/master/LICENSE)
[![CircleCI](https://img.shields.io/circleci/project/github/jdee/react_native_convert.svg)](https://circleci.com/gh/jdee/react_native_convert)

**Work in progress**

Conversion tools for React Native projects.

```bash
git clone https://github.com/jdee/react_native_convert
cd react_native_convert
bundle check || bundle install
[sudo] bundle exec rake install:local
react_native_convert -h
```

## Gemfile

```Ruby
gem 'react_native_convert', git: 'https://github.com/jdee/react_native_convert'
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
react_native_convert react_pod
git status
```
