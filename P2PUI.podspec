Pod::Spec.new do |s|

  s.name         = "P2PUI"
  s.version      = "0.3"
  s.summary      = "P2PCore - UI Framework for Wallet One P2P"

  s.homepage     = "https://github.com/WalletOne/P2P.git"

  s.license = 'MIT'

  s.author             = { "Vitaliy" => "vitaly.kuzmenko@walletone.com" }

  s.ios.deployment_target = '8.0'

  s.source       = { :git => s.homepage, :tag => s.version.to_s }

  s.pod_target_xcconfig = { 'SWIFT_VERSION' => '4.0' }

  s.source_files  = "P2PUI/**/*.swift"
  
  s.dependency 'P2PCore', '0.3'
  
  s.resources = 'P2PUI/**/*.{xib,png,bundle}'
  
end
