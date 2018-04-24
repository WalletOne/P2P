Pod::Spec.new do |s|

  s.name         = "P2PCore"
  s.version      = "0.3.4"
  s.summary      = "P2PCore - Framework for network requests Wallet One P2P"

  s.homepage     = "https://github.com/WalletOne/P2P.git"

  s.license = 'MIT'

  s.author = { "Vitaliy" => "vitaly.kuzmenko@walletone.com" }

  s.ios.deployment_target = '8.0'

  s.source       = { :git => s.homepage, :tag => s.version.to_s }

  s.pod_target_xcconfig = { 'SWIFT_VERSION' => '4.1' }

  s.source_files  = 'P2PCore/**/*.swift'
  
  s.dependency 'CryptoSwift', '0.9.0'
   
end
