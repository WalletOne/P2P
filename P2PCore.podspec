Pod::Spec.new do |s|

  s.name         = "P2PCore"
  s.version      = "0.0.1"
  s.summary      = "P2PCore - Framework for network requests Wallet One P2P"

  s.homepage     = "https://github.com/WalletOne/P2P.git"

  s.license = 'MIT'

  s.author             = { "Vitaliy" => "vitaly.kuzmenko@walletone.com" }

  s.ios.deployment_target = '8.0'

  s.source       = { :git => s.homepage, :tag => s.version.to_s }

  s.source_files  = "P2PCore/**/*.swift"
  
  s.requires_arc = 'true'
  
  s.pod_target_xcconfig = {
    'SWIFT_VERSION' => '3.0',
  }
  
  s.preserve_paths = 'CocoaPods/**/*'
  
  s.pod_target_xcconfig = {
    'SWIFT_INCLUDE_PATHS[sdk=macosx*]'           => '$(PODS_ROOT)/P2PCore/CocoaPods/macosx',
    'SWIFT_INCLUDE_PATHS[sdk=iphoneos*]'         => '$(PODS_ROOT)/P2PCore/CocoaPods/iphoneos',
    'SWIFT_INCLUDE_PATHS[sdk=iphonesimulator*]'  => '$(PODS_ROOT)/P2PCore/CocoaPods/iphonesimulator',
    'SWIFT_INCLUDE_PATHS[sdk=appletvos*]'        => '$(PODS_ROOT)/P2PCore/CocoaPods/appletvos',
    'SWIFT_INCLUDE_PATHS[sdk=appletvsimulator*]' => '$(PODS_ROOT)/P2PCore/CocoaPods/appletvsimulator',
    'SWIFT_INCLUDE_PATHS[sdk=watchos*]'          => '$(PODS_ROOT)/P2PCore/CocoaPods/watchos',
    'SWIFT_INCLUDE_PATHS[sdk=watchsimulator*]'   => '$(PODS_ROOT)/P2PCore/CocoaPods/watchsimulator'
}
   
end
