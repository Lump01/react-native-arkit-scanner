#import <React/RCTBridgeModule.h>
#import <React/RCTViewManager.h>
#import <React/RCTEventDispatcher.h>
#import <React/RCTUtils.h>

@interface RCT_EXTERN_MODULE(RNARKitScanner, NSObject)

// Scanning methods
RCT_EXTERN_METHOD(startScan:(RCTPromiseResolveBlock)resolve
        rejecter:(RCTPromiseRejectBlock)reject)
RCT_EXTERN_METHOD(stopScan:(RCTPromiseResolveBlock)resolve
        rejecter:(RCTPromiseRejectBlock)reject)

// Export methods
RCT_EXTERN_METHOD(exportUSDZ:(RCTPromiseResolveBlock)resolve
        rejecter:(RCTPromiseRejectBlock)reject)
RCT_EXTERN_METHOD(exportOBJ:(RCTPromiseResolveBlock)resolve
        rejecter:(RCTPromiseRejectBlock)reject)
RCT_EXTERN_METHOD(exportSTL:(RCTPromiseResolveBlock)resolve
        rejecter:(RCTPromiseRejectBlock)reject)

// Upload method
RCT_EXTERN_METHOD(uploadFile:(NSString *)filePath
        uploadUrl:(NSString *)uploadUrl
        resolve:(RCTPromiseResolveBlock)resolve
        rejecter:(RCTPromiseRejectBlock)reject)

@end
