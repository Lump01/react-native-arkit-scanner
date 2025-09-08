import Foundation
import ARKit
import SceneKit
import ModelIO

@objc(RNARKitScanner)
class RNARKitScanner: NSObject {
    static var sceneView: ARSCNView?
    static var capturedScene: SCNScene?

    @objc func startScan() {
        DispatchQueue.main.async {
            let sceneView = ARSCNView(frame: UIScreen.main.bounds)
            sceneView.automaticallyUpdatesLighting = true
            let config = ARWorldTrackingConfiguration()
            if #available(iOS 13.4, *) {
                config.sceneReconstruction = .mesh
            }
            config.environmentTexturing = .automatic
            sceneView.session.run(config)
            RNARKitScanner.sceneView = sceneView
        }
    }

    @objc func stopScan() {
        DispatchQueue.main.async {
            RNARKitScanner.sceneView?.session.pause()
            RNARKitScanner.capturedScene = RNARKitScanner.sceneView?.scene
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
            let asset = MDLAsset(scnScene: scene)
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
            var stl = "solid scan\n"
            for node in scene.rootNode.childNodes {
                if let geom = node.geometry {
                    for element in geom.sources {
                        if element.semantic == .vertex {
                            let verts = element.data
                            stl += "  facet normal 0 0 0\n"
                            stl += "    outer loop\n"
                            // simplified export for demo
                            stl += "    endloop\n"
                            stl += "  endfacet\n"
                        }
                    }
                }
            }
            stl += "endsolid scan\n"
            try stl.write(to: url, atomically: true, encoding: .utf8)
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
