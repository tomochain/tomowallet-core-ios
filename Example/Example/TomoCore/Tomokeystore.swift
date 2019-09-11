//
//  Tomokeystore.swift
//  Example
//
//  Created by Admin on 8/29/19.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import UIKit
import KeychainSwift
import RealmSwift
import Result
import BigInt

enum WalletInfoField {
    case name(String)
    case backup(Bool)
    case mainWallet(Bool)
    case balance(String)
}

enum ImportType{
    case PrivateKey(privateKey: String)
    case memnonic(memnonic: String)
}
class TomoKeystore {
 
    var hasWallets: Bool{
        return true
    }
    

    public static let keychainKeyPrefix = "tomowallet"
    private let datadir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
    let keysDirectory: URL
    let keyStore: KeyStore
    
    // set keychain save password lock account
    private let keychain: KeychainSwift
    private let defaultKeychainAccess: KeychainSwiftAccessOptions = .accessibleWhenUnlockedThisDeviceOnly
    
    // StoreWalletInfo
    private let storage: TomoWalletStorage
    private func realm(for config: Realm.Configuration) -> Realm {
        return try! Realm(configuration: config)
    }
    
    var wallets: [TomoWalletService] {
        return
            keyStore.wallets.map {
                switch $0.type{
                case .encryptedKey:
                    let type = TomoWalletType.privateKey($0)
                    return TomoWalletService(type: type, keyStore: self)
                case .hierarchicalDeterministicWallet:
                    let type = TomoWalletType.hd($0)
                    return TomoWalletService(type: type, keyStore: self)
                }
            }

       
    }
    
    let network: TomoChainNetwork

    init(network: TomoChainNetwork) {
        // keystore init
        keysDirectory = URL(fileURLWithPath: datadir! + "/keystore")
        keyStore = try! KeyStore(keyDirectory: keysDirectory)
        
        // keychain init
        keychain = KeychainSwift(keyPrefix: Constants.keychainKeyPrefix)
        
        // store wallet info init
        let sharedMigration = SharedMigrationInitializer()
        sharedMigration.perform()
        let realm = try! Realm(configuration: sharedMigration.config)
        storage = TomoWalletStorage(realm: realm)
        
        self.network = network
    }

    func createAccout( password: String, coin: Coin) -> Wallet?  {
     
        do {
            let wallet = try self.keyStore.createWallet(password: password, derivationPaths: [coin.derivationPath(at: 0)])
            // check not save password to keychain
            if setPassword(password, for: wallet){
                return wallet
            }else{
                try! FileManager().removeItem(at: wallet.keyURL)
                return .none
            }
        } catch {
            return .none
        }
        
        
    }
    func importWalletPrivatekey(privatekey: String, completion: @escaping()->()) {
        
    }
    
    
    func getPassword(for account:Wallet) -> String? {
        let key = keychainKey(for: account)
        return keychain.get(key)
    }
    
    @discardableResult
    func setPassword(_ password: String, for account: Wallet) -> Bool {
        let key = keychainKey(for: account)
        return keychain.set(password, forKey: key, withAccess: defaultKeychainAccess)
    }
    internal func keychainKey(for account: Wallet) -> String {
        return account.identifier
    }
    
    func store(object: TomoWalletObject, fields: [WalletInfoField]) {
        try? storage.realm.write {
            for field in fields {
                switch field {
                case .name(let name):
                    object.name = name
                case .backup(let completedBackup):
                    object.completedBackup = completedBackup
                case .mainWallet(let mainWallet):
                    object.mainWallet = mainWallet
                case .balance(let balance):
                    object.balance = balance
                }
            }
            storage.realm.add(object, update: true)
        }
    }
    
    func signPersonalMessage(_ message: Data, for account: Account) -> Result<Data, TomoKeystoreError> {
        let prefix = "\u{19}Ethereum Signed Message:\n\(message.count)".data(using: .utf8)!
        return signMessage(prefix + message, for: account)
    }
    
    func signMessage(_ message: Data, for account: Account) -> Result<Data, TomoKeystoreError> {
        return signHash(message.sha3(.keccak256), for: account)
    }
    func signTypedMessage(_ datas: [EthTypedData], for account: Account) -> Result<Data, TomoKeystoreError> {
        let schemas = datas.map { $0.schemaData }.reduce(Data(), { $0 + $1 }).sha3(.keccak256)
        let values = datas.map { $0.typedData }.reduce(Data(), { $0 + $1 }).sha3(.keccak256)
        let combined = (schemas + values).sha3(.keccak256)
        return signHash(combined, for: account)
    }
    
    
    func signHash(_ hash: Data, for account: Account) -> Result<Data, TomoKeystoreError> {
        guard
            let password = getPassword(for: account.wallet!) else {
                return .failure(TomoKeystoreError.failedToSignMessage)
        }
        do {
            var data = try account.sign(hash: hash, password: password)
            // TODO: Make it configurable, instead of overriding last byte.
            data[64] += 27
            return .success(data)
        } catch {
            return .failure(TomoKeystoreError.failedToSignMessage)
        }
    }
    
    func signTransaction(_ transaction: SignTransaction, for account: Account) -> Result<Data, TomoKeystoreError> {
        guard let wallet  = account.wallet, let password = getPassword(for: wallet) else {
            return .failure(.failedToSignTransaction)
        }
        let signer: Signer
        if transaction.chainID == 0 {
            signer = HomesteadSigner()
        } else {
            signer = EIP155Signer(chainId: BigInt(transaction.chainID))
        }
        
        do {
            let hash = signer.hash(transaction: transaction)
            let signature = try account.sign(hash: hash, password: password)
            let (r, s, v) = signer.values(transaction: transaction, signature: signature)
            let data = RLP.encode([
                transaction.nonce,
                transaction.gasPrice,
                transaction.gasLimit,
                transaction.to?.data ?? Data(),
                transaction.value,
                transaction.data,
                v, r, s,
                ])!
            return .success(data)
        } catch {
            return .failure(.failedToSignTransaction)
        }
    }
    
}
extension TomoKeystore: TomoKeystoreProtocol{
    func getwallets() -> [TomoWallet] {
        return wallets
    }
    
    func createWallet(completion: @escaping (Result<TomoWallet, TomoKeystoreError>) -> Void) {
        let password = PasswordGenerator.generateRandom()
        DispatchQueue.global(qos: .userInitiated).async {
            if let wallet = self.createAccout(password: password, coin: .tomo){
                DispatchQueue.main.async {
                    let tomoWallet = TomoWalletService(type: TomoWalletType.hd(wallet), keyStore: self)
                    completion(.success(tomoWallet))
                }
            }else{
                DispatchQueue.main.async {
                    completion(.failure(.failedToAddAccounts))
                }
            }
        }
    }
    

    
    func getWallet(address: String, completion: @escaping (Result<TomoWallet, TomoKeystoreError>) -> Void) {
        guard let etherAddress = EthereumAddress(string: address) else {
            completion(.failure(TomoKeystoreError.invalidAddress))
            return
        }
        let tomoWallet = wallets.filter{ $0.address.lowercased() == etherAddress.description.lowercased()}.first
        if let wallet = tomoWallet{
            completion(.success(wallet))
        }else{
            completion(.failure(TomoKeystoreError.accountNotFound))
        }
    }
}

extension Coin {
    public func derivationPath(at index: Int) -> DerivationPath {
        return DerivationPath(purpose: 44, coinType: self.rawValue, account: 0, change: 0, address: index)
    }
}



