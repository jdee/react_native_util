/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 *
 * @format
 * @flow
 */

import React, {Component} from 'react';
import {Platform, StyleSheet, Text, View} from 'react-native';
import {WebView} from 'react-native-webview';

type Props = {};
export default class App extends Component<Props> {
  render() {
    return (
      <WebView
        style={styles.containers}
        source={{uri: 'https://www.reactnative.com'}}
      />
    );
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#F5FCFF',
  },
});
