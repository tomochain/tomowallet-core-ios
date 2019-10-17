
Pod::Spec.new do |s|
  s.name         = 'TomoWalletCore'
  s.version      = '0.0.6'
  s.summary      = 'A general-purpose TomoWallet.'
  s.homepage     = "https://github.com/tomochain/tomowallet-core-ios"
  s.license      = 'MIT'
  s.authors      = { 'CanDang' => 'candd1707@gmail.com' }

  s.ios.deployment_target = '11.1'  
  s.swift_version = "4.2"
  s.dependency 'BigInt'
  s.dependency 'CryptoSwift'
  s.dependency 'TrezorCrypto', '~> 0.0.8'
  s.dependency 'Moya'
  s.dependency 'PromiseKit'
  s.dependency 'SwiftProtobuf'
  s.dependency 'KeychainSwift'
 

  s.source       = { git: 'https://github.com/tomochain/tomowallet-core-ios.git', tag: s.version }
 s.source_files = 'TomoWalletCore/TomoWalletcore/**/*.{swift,h,m}'
  s.public_header_files = 'TomoWalletCore/TomoWalletcore/TomoWalletCore.h', 'TomoWalletCore/TomoWalletcore/Crypto.h'



  s.pod_target_xcconfig = { 'SWIFT_OPTIMIZATION_LEVEL' => '-Owholemodule' }
end