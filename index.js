import { NativeModules } from 'react-native';
const { RNARKitScanner } = NativeModules;

export const Scanner = {
    startScan: () => RNARKitScanner.startScan(),
    stopScan: () => RNARKitScanner.stopScan(),
    exportUSDZ: async () => await RNARKitScanner.exportUSDZ(),
    exportOBJ: async () => await RNARKitScanner.exportOBJ(),
    exportSTL: async () => await RNARKitScanner.exportSTL(),
    uploadFile: async (filePath, uploadUrl) => await RNARKitScanner.uploadFile(filePath, uploadUrl),
};
