
Pod::Spec.new do |s|
  s.name         = 'TomoWalletCore'
  s.version      = '0.0.1'
  s.summary      = 'A general-purpose TomoWallet.'
  s.homepage     = "https://github.com/tunght91/tomowallet-ios-core"
  s.license      = 'MIT'
  s.authors      = { 'CanDang' => 'candd1707@gmail.com' }

  s.ios.deployment_target = '11.1'  
  s.swift_version = "4.2"

  s.source       = { git: 'https://github.com/tunght91/tomowallet-ios-core', tag: s.version }
  s.source_files = "TomoWalletCore/**/*.{h,m,swift}"

  s.dependency 'BigInt'
  s.dependency 'CryptoSwift'
  s.dependency 'TrezorCrypto'
  s.dependency 'Moya'
  s.dependency 'PromiseKit'
  s.dependency 'KeychainSwift'
  s.dependency 'SwiftProtobuf'

  s.pod_target_xcconfig = { 'SWIFT_OPTIMIZATION_LEVEL' => '-Owholemodule' }
end