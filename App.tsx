/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 *
 * @format
 */

import React, {useState} from 'react';
import {
  Button,
  SafeAreaView,
  StatusBar,
  StyleSheet,
  TextInput,
  useColorScheme,
} from 'react-native';

import {Colors} from 'react-native/Libraries/NewAppScreen';
import SharedGroupPreferences from 'react-native-shared-group-preferences';

const group = 'group.RNLockscreenWidget';

function App(): JSX.Element {
  const isDarkMode = useColorScheme() === 'dark';
  const [text, setText] = useState('');

  const backgroundStyle = {
    backgroundColor: isDarkMode ? Colors.darker : Colors.lighter,
  };

  const widgetData = {
    text,
    minGaugeVal: 0,
    maxGaugeVal: 100,
    currentGaugeVal: 80,
    icon: 'scooter',
  };

  const handleSubmit = async () => {
    console.log('in handle submit');
    try {
      // iOS
      await SharedGroupPreferences.setItem('widgetKey', widgetData, group);
    } catch (error) {
      console.log({error});
    }
  };

  return (
    <SafeAreaView style={backgroundStyle}>
      <StatusBar
        barStyle={isDarkMode ? 'light-content' : 'dark-content'}
        backgroundColor={backgroundStyle.backgroundColor}
      />
      <TextInput
        style={styles.input}
        onChangeText={newText => setText(newText)}
        value={text}
        returnKeyType="send"
        placeholder="Enter the text to display..."
      />
      <Button onPress={handleSubmit} title="set props" />
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  sectionContainer: {
    marginTop: 32,
    paddingHorizontal: 24,
  },
  sectionTitle: {
    fontSize: 24,
    fontWeight: '600',
  },
  sectionDescription: {
    marginTop: 8,
    fontSize: 18,
    fontWeight: '400',
  },
  highlight: {
    fontWeight: '700',
  },
  input: {
    width: '100%',
    borderBottomWidth: 1,
    fontSize: 20,
    minHeight: 40,
  },
});

export default App;
