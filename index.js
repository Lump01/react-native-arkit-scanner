import { NativeModules } from 'react-native';
import ARScanner from './ARScanner';

const { RNARKitScanner } = NativeModules;

export const Scanner = {
    startScan: async () => await RNARKitScanner.startScan(),
    stopScan: async () => await RNARKitScanner.stopScan(),
    exportUSDZ: async () => await RNARKitScanner.exportUSDZ(),
    exportOBJ: async () => await RNARKitScanner.exportOBJ(),
    exportSTL: async () => await RNARKitScanner.exportSTL(),
    uploadFile: async (filePath, uploadUrl) => await RNARKitScanner.uploadFile(filePath, uploadUrl),
};

export { ARScanner };
