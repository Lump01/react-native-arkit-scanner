import Foundation
import ARKit
import SceneKit
import ModelIO
import React

// Define typealias for React Native promise blocks
typealias RCTPromiseResolveBlock = @convention(block) (Any?) -> Void
typealias RCTPromiseRejectBlock = @convention(block) (String?, String?, Error?) -> Void

@objc(RNARKitScanner)
class RNARKitScanner: NSObject {
    static var sceneView: ARSCNView?
    static var capturedScene: SCNScene?

    @objc func startScan(_ resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        DispatchQueue.main.async {
            // Check if ARKit is supported
            guard ARWorldTrackingConfiguration.isSupported else {
                reject("arkit_not_supported", "ARKit is not supported on this device", nil)
                return
            }

            let sceneView = ARSCNView(frame: UIScreen.main.bounds)
            sceneView.automaticallyUpdatesLighting = true
            let config = ARWorldTrackingConfiguration()

            // Check and configure scene reconstruction
            if #available(iOS 13.4, *) {
                if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) {
                    config.sceneReconstruction = .mesh
                    print("Scene reconstruction enabled")
                } else {
                    print("Scene reconstruction not supported on this device")
                }
            } else {
                print("iOS version does not support scene reconstruction")
            }

            // Set environment texturing only if supported
            if ARWorldTrackingConfiguration.isSupported {
                config.environmentTexturing = .automatic
            }

            sceneView.session.run(config)
            RNARKitScanner.sceneView = sceneView
            resolve("Scan started")
        }
    }

    @objc func stopScan(_ resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        DispatchQueue.main.async {
            RNARKitScanner.sceneView?.session.pause()
            RNARKitScanner.capturedScene = RNARKitScanner.sceneView?.scene
            resolve("Scan stopped")
        }
    }

    @objc func exportUSDZ(_ resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        guard let scene = RNARKitScanner.capturedScene else {
            reject("no_scene", "No scene captured", nil)
            return
        }
        let url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("scan.usdz")
        do {
            try scene.write(to: url, options: nil, delegate: nil, progressHandler: nil)
            resolve(url.path)
        } catch {
            reject("export_error", error.localizedDescription, error)
        }
    }

    @objc func exportOBJ(_ resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        guard let scene = RNARKitScanner.capturedScene else {
            reject("no_scene", "No scene captured", nil)
            return
        }
        let url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("scan.obj")
        do {
            let asset = MDLAsset()

            scene.rootNode.enumerateChildNodes { (node, _) in
                if let geometry = node.geometry {
                    // Convert SCNGeometry to MDLMesh
                    let mdlMesh = MDLMesh(scnGeometry: geometry)
                    asset.add(mdlMesh)
                }
            }

            try asset.export(to: url)
            resolve(url.path)
        } catch {
            reject("export_error", error.localizedDescription, error)
        }
    }

    @objc func exportSTL(_ resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        guard let scene = RNARKitScanner.capturedScene else {
            reject("no_scene", "No scene captured", nil)
            return
        }
        let url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("scan.stl")
        do {
            // Convert SCNScene to MDLAsset
            let asset = MDLAsset(scnScene: scene)

            // Create binary STL data
            let allocator = MDLMeshBufferDataAllocator()
            let data = allocator.newBuffer(with: Data(), type: .vertex)

            // Export to STL using ModelIO
            let stlAsset = MDLAsset()

            // Add each mesh from the original asset to the STL asset
            for mesh in asset.meshes {
                let stlMesh = mesh.copy() as! MDLMesh
                stlAsset.add(stlMesh)
            }

            // Export the STL file
            try stlAsset.export(to: url)
            resolve(url.path)
        } catch {
            reject("export_error", error.localizedDescription, error)
        }
    }

    @objc func uploadFile(_ filePath: String, uploadUrl: String, resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        let url = URL(fileURLWithPath: filePath)
        guard FileManager.default.fileExists(atPath: filePath) else {
            reject("file_not_found", "File does not exist", nil)
            return
        }
        var request = URLRequest(url: URL(string: uploadUrl)!)
        request.httpMethod = "POST"
        let task = URLSession.shared.uploadTask(with: request, fromFile: url) { data, response, error in
            if let error = error {
                reject("upload_error", error.localizedDescription, error)
            } else {
                resolve("Uploaded to \(uploadUrl)")
            }
        }
        task.resume()
    }
}
