Pod::Spec.new do |s|
  s.name         = "react-native-arkit-scanner"
  s.version      = "0.0.1"
  s.summary      = "React Native ARKit LiDAR scanning and 3D model export"
  s.description  = <<-DESC
                   A React Native bridge to Apple ARKit, enabling LiDAR scanning
                   and exporting 3D models (USDZ, OBJ, STL).
                   DESC
  s.license      = "MIT"
  s.author       = { "Your Name" => "you@example.com" }
  s.homepage     = "https://github.com/your/repo"
  s.platforms    = { :ios => "14.0" }

  # For local development, you don't need source
  s.source       = { :git => "https://example.com/fake.git", :tag => "0.0.1" }

  s.source_files = "RNARKitScanner.swift", "RNARKitScannerManagerBridge.m"
  s.requires_arc = true
  s.swift_version = "5.0"

  # Link Apple frameworks
  s.frameworks   = ["ARKit", "SceneKit", "ModelIO"]
end
