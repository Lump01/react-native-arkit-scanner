# React Native ARKit Scanner

A React Native package for iOS that utilizes ARKit to scan real-life objects and export them as 3D models in various formats.

## Features

- Scan real-world objects using ARKit and LiDAR on compatible iOS devices
- Export scanned objects in multiple 3D file formats:
  - USDZ (Universal Scene Description)
  - OBJ (Wavefront)
  - STL (Stereolithography)
- Ready-to-use React Native component with a complete UI
- Share exported 3D models directly from your app
- Upload 3D models to your server

## Requirements

- iOS 14.0 or later
- iPhone or iPad with LiDAR sensor (iPhone 12 Pro/Pro Max or newer, iPad Pro 2020 or newer)
- React Native 0.70.0 or later
- React 17.0.0 or later

## Installation

```bash
npm install react-native-arkit-scanner
# or
yarn add react-native-arkit-scanner
```

### iOS Setup

1. Add the following to your `Info.plist` file to request camera permissions:

```xml
<key>NSCameraUsageDescription</key>
<string>This app needs camera access to scan 3D objects</string>
```

2. Make sure your deployment target is set to iOS 14.0 or higher in your Podfile:

```ruby
platform :ios, '14.0'
```

3. Install the pods:

```bash
cd ios && pod install
```

## Usage

### Using the ARScanner Component

The easiest way to integrate 3D scanning is to use the provided `ARScanner` component:

```jsx
import React from 'react';
import { SafeAreaView, StyleSheet } from 'react-native';
import { ARScanner } from 'react-native-arkit-scanner';

const App = () => {
  const handleScanComplete = (result) => {
    console.log(`Scan exported as ${result.format} to ${result.filePath}`);
    // You can now use the file path to display, share, or upload the 3D model
  };

  return (
    <SafeAreaView style={styles.container}>
      <ARScanner 
        style={styles.scanner}
        onScanComplete={handleScanComplete}
      />
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  scanner: {
    flex: 1,
  },
});

export default App;
```

### Using the Scanner API Directly

If you prefer to build your own UI, you can use the Scanner API directly:

```jsx
import React, { useState } from 'react';
import { View, Button, Text, Alert } from 'react-native';
import { Scanner } from 'react-native-arkit-scanner';

const CustomScannerScreen = () => {
  const [scanning, setScanning] = useState(false);
  const [filePath, setFilePath] = useState(null);

  const startScanning = async () => {
    try {
      await Scanner.startScan();
      setScanning(true);
    } catch (error) {
      Alert.alert('Error', error.message);
    }
  };

  const stopScanning = async () => {
    try {
      await Scanner.stopScan();
      setScanning(false);
    } catch (error) {
      Alert.alert('Error', error.message);
    }
  };

  const exportAsOBJ = async () => {
    try {
      const path = await Scanner.exportOBJ();
      setFilePath(path);
    } catch (error) {
      Alert.alert('Export Error', error.message);
    }
  };

  return (
    <View style={{ flex: 1, justifyContent: 'center', alignItems: 'center' }}>
      {scanning ? (
        <Button title="Stop Scanning" onPress={stopScanning} />
      ) : (
        <Button title="Start Scanning" onPress={startScanning} />
      )}
      
      {!scanning && (
        <>
          <Button title="Export as OBJ" onPress={exportAsOBJ} />
          {filePath && <Text>Exported to: {filePath}</Text>}
        </>
      )}
    </View>
  );
};

export default CustomScannerScreen;
```

## API Reference

### Scanner API

#### `startScan()`

Starts the ARKit scanning session.

```js
try {
  await Scanner.startScan();
  // Scanning started
} catch (error) {
  // Handle error
}
```

#### `stopScan()`

Stops the current scanning session and captures the scene.

```js
try {
  await Scanner.stopScan();
  // Scanning stopped, scene captured
} catch (error) {
  // Handle error
}
```

#### `exportUSDZ()`

Exports the captured scene as a USDZ file.

```js
try {
  const filePath = await Scanner.exportUSDZ();
  // Use filePath
} catch (error) {
  // Handle error
}
```

#### `exportOBJ()`

Exports the captured scene as an OBJ file.

```js
try {
  const filePath = await Scanner.exportOBJ();
  // Use filePath
} catch (error) {
  // Handle error
}
```

#### `exportSTL()`

Exports the captured scene as an STL file.

```js
try {
  const filePath = await Scanner.exportSTL();
  // Use filePath
} catch (error) {
  // Handle error
}
```

#### `uploadFile(filePath, uploadUrl)`

Uploads a file to a specified URL.

```js
try {
  await Scanner.uploadFile(filePath, 'https://your-server.com/upload');
  // File uploaded successfully
} catch (error) {
  // Handle error
}
```

### ARScanner Component

#### Props

| Prop | Type | Description |
|------|------|-------------|
| `style` | Object | Style object for the scanner container |
| `onScanComplete` | Function | Callback function that receives the export result `{ format, filePath }` |

## Best Practices for 3D Scanning

1. **Good lighting**: Ensure the object is well-lit from all sides
2. **Move slowly**: Move your device slowly around the object
3. **Capture all angles**: Try to scan the object from all angles for best results
4. **Avoid reflective surfaces**: Shiny or transparent objects are difficult to scan
5. **Appropriate size**: Objects between 10cm and 3m work best

## Troubleshooting

### Common Issues

- **"ARKit is not supported on this device"**: Make sure you're using a device with LiDAR (iPhone 12 Pro/Pro Max or newer, iPad Pro 2020 or newer)
- **Poor scan quality**: Ensure good lighting and move slowly around the object
- **Export fails**: Make sure you've completed a scan before attempting to export

## License

MIT
