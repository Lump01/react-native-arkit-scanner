import React, { useState, useEffect } from 'react';
import {
  View,
  Text,
  TouchableOpacity,
  StyleSheet,
  ActivityIndicator,
  Alert,
  Share,
  Platform,
} from 'react-native';
import { Scanner } from './index';

const ARScanner = ({ onScanComplete, style }) => {
  const [scanning, setScanning] = useState(false);
  const [exporting, setExporting] = useState(false);
  const [exportFormat, setExportFormat] = useState(null);
  const [exportedFilePath, setExportedFilePath] = useState(null);

  const startScan = async () => {
    try {
      setScanning(true);
      await Scanner.startScan();
    } catch (error) {
      Alert.alert('Error', 'Failed to start scanning: ' + error.message);
      setScanning(false);
    }
  };

  const stopScan = async () => {
    try {
      await Scanner.stopScan();
      setScanning(false);
    } catch (error) {
      Alert.alert('Error', 'Failed to stop scanning: ' + error.message);
    }
  };

  const exportScan = async (format) => {
    if (!format || !['USDZ', 'OBJ', 'STL'].includes(format)) {
      Alert.alert('Error', 'Invalid export format');
      return;
    }

    try {
      setExporting(true);
      setExportFormat(format);

      let filePath;
      switch (format) {
        case 'USDZ':
          filePath = await Scanner.exportUSDZ();
          break;
        case 'OBJ':
          filePath = await Scanner.exportOBJ();
          break;
        case 'STL':
          filePath = await Scanner.exportSTL();
          break;
      }

      setExportedFilePath(filePath);

      if (onScanComplete) {
        onScanComplete({
          format,
          filePath,
        });
      }

      return filePath;
    } catch (error) {
      Alert.alert('Export Error', `Failed to export as ${format}: ${error.message}`);
      return null;
    } finally {
      setExporting(false);
      setExportFormat(null);
    }
  };

  const shareFile = async () => {
    if (!exportedFilePath) {
      Alert.alert('Error', 'No file to share');
      return;
    }

    try {
      const result = await Share.share({
        url: Platform.OS === 'ios' ? `file://${exportedFilePath}` : exportedFilePath,
        message: 'Check out this 3D scan!',
      });
    } catch (error) {
      Alert.alert('Share Error', error.message);
    }
  };

  const uploadFile = async (uploadUrl) => {
    if (!exportedFilePath) {
      Alert.alert('Error', 'No file to upload');
      return;
    }

    if (!uploadUrl) {
      Alert.alert('Error', 'No upload URL provided');
      return;
    }

    try {
      const result = await Scanner.uploadFile(exportedFilePath, uploadUrl);
      Alert.alert('Success', 'File uploaded successfully');
      return result;
    } catch (error) {
      Alert.alert('Upload Error', error.message);
      return null;
    }
  };

  return (
    <View style={[styles.container, style]}>
      {scanning ? (
        <View style={styles.scanningContainer}>
          <Text style={styles.scanningText}>Scanning in progress...</Text>
          <Text style={styles.scanningSubText}>Move your device around the object</Text>
          <TouchableOpacity
            style={[styles.button, styles.stopButton]}
            onPress={stopScan}
          >
            <Text style={styles.buttonText}>Stop Scanning</Text>
          </TouchableOpacity>
        </View>
      ) : exportedFilePath ? (
        <View style={styles.exportedContainer}>
          <Text style={styles.exportedText}>Scan Exported!</Text>
          <Text style={styles.exportedSubText}>File saved at: {exportedFilePath}</Text>

          <View style={styles.actionRow}>
            <TouchableOpacity
              style={[styles.button, styles.shareButton]}
              onPress={shareFile}
            >
              <Text style={styles.buttonText}>Share</Text>
            </TouchableOpacity>

            <TouchableOpacity
              style={[styles.button, styles.newScanButton]}
              onPress={() => {
                setExportedFilePath(null);
              }}
            >
              <Text style={styles.buttonText}>New Scan</Text>
            </TouchableOpacity>
          </View>
        </View>
      ) : exporting ? (
        <View style={styles.exportingContainer}>
          <ActivityIndicator size="large" color="#0000ff" />
          <Text style={styles.exportingText}>
            Exporting as {exportFormat}...
          </Text>
        </View>
      ) : (
        <View style={styles.controlsContainer}>
          <TouchableOpacity
            style={[styles.button, styles.scanButton]}
            onPress={startScan}
          >
            <Text style={styles.buttonText}>Start Scanning</Text>
          </TouchableOpacity>

          <Text style={styles.exportTitle}>Export Previous Scan:</Text>

          <View style={styles.exportRow}>
            <TouchableOpacity
              style={[styles.exportButton, styles.usdzButton]}
              onPress={() => exportScan('USDZ')}
            >
              <Text style={styles.exportButtonText}>USDZ</Text>
            </TouchableOpacity>

            <TouchableOpacity
              style={[styles.exportButton, styles.objButton]}
              onPress={() => exportScan('OBJ')}
            >
              <Text style={styles.exportButtonText}>OBJ</Text>
            </TouchableOpacity>

            <TouchableOpacity
              style={[styles.exportButton, styles.stlButton]}
              onPress={() => exportScan('STL')}
            >
              <Text style={styles.exportButtonText}>STL</Text>
            </TouchableOpacity>
          </View>
        </View>
      )}
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: 'rgba(0, 0, 0, 0.7)',
    justifyContent: 'center',
    alignItems: 'center',
  },
  scanningContainer: {
    alignItems: 'center',
    padding: 20,
  },
  scanningText: {
    fontSize: 24,
    fontWeight: 'bold',
    color: 'white',
    marginBottom: 10,
  },
  scanningSubText: {
    fontSize: 16,
    color: 'white',
    marginBottom: 30,
    textAlign: 'center',
  },
  exportingContainer: {
    alignItems: 'center',
    padding: 20,
  },
  exportingText: {
    fontSize: 18,
    color: 'white',
    marginTop: 20,
  },
  exportedContainer: {
    alignItems: 'center',
    padding: 20,
  },
  exportedText: {
    fontSize: 24,
    fontWeight: 'bold',
    color: 'white',
    marginBottom: 10,
  },
  exportedSubText: {
    fontSize: 14,
    color: 'white',
    marginBottom: 30,
    textAlign: 'center',
  },
  controlsContainer: {
    alignItems: 'center',
    padding: 20,
  },
  button: {
    paddingVertical: 12,
    paddingHorizontal: 30,
    borderRadius: 25,
    marginVertical: 10,
    minWidth: 200,
    alignItems: 'center',
  },
  buttonText: {
    fontSize: 18,
    fontWeight: 'bold',
    color: 'white',
  },
  scanButton: {
    backgroundColor: '#4CAF50',
  },
  stopButton: {
    backgroundColor: '#F44336',
  },
  shareButton: {
    backgroundColor: '#2196F3',
    marginHorizontal: 5,
  },
  newScanButton: {
    backgroundColor: '#4CAF50',
    marginHorizontal: 5,
  },
  exportTitle: {
    fontSize: 18,
    color: 'white',
    marginTop: 30,
    marginBottom: 10,
  },
  exportRow: {
    flexDirection: 'row',
    justifyContent: 'center',
    marginTop: 10,
  },
  actionRow: {
    flexDirection: 'row',
    justifyContent: 'center',
  },
  exportButton: {
    paddingVertical: 10,
    paddingHorizontal: 20,
    borderRadius: 5,
    marginHorizontal: 5,
    minWidth: 80,
    alignItems: 'center',
  },
  exportButtonText: {
    fontSize: 16,
    fontWeight: 'bold',
    color: 'white',
  },
  usdzButton: {
    backgroundColor: '#9C27B0',
  },
  objButton: {
    backgroundColor: '#FF9800',
  },
  stlButton: {
    backgroundColor: '#00BCD4',
  },
});

export default ARScanner;
