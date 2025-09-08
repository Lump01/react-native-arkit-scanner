Pod::Spec.new do |s|
  s.name         = "react-native-arkit-scanner"
  s.version      = "1.0.0"
  s.summary      = "React Native ARKit LiDAR scanning and 3D model export"
  s.description  = <<-DESC
                   A React Native bridge to Apple ARKit, enabling LiDAR scanning
                   and exporting 3D models in multiple formats (USDZ, OBJ, STL).
                   Provides both a low-level API and a ready-to-use UI component.
                   DESC
  s.license      = "MIT"
  s.author       = { "Your Name" => "your.email@example.com" }
  s.homepage     = "https://github.com/Lump01/react-native-arkit-scanner"
  s.platforms    = { :ios => "14.0" }

  s.source       = { :git => "https://github.com/Lump01/react-native-arkit-scanner.git", :tag => "v#{s.version}" }

  s.source_files = "ios/RNARKitScanner.swift", "ios/RNARKitScannerManagerBridge.m"
  s.requires_arc = true
  s.swift_version = "5.0"

  # Link Apple frameworks
  s.frameworks   = ["ARKit", "SceneKit", "ModelIO"]

  s.dependency "React"
  s.dependency "React-Core"
  s.dependency "React-callinvoker"
end
