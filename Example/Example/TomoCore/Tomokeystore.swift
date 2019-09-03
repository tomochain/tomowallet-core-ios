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
    init() {
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
}
extension TomoKeystore: TomoKeystoreProtocol{
 
    func createWallet(completion: @escaping (Result<TomoWallet, TomoKeystoreError>) -> Void) {
        let password = PasswordGenerator.generateRandom()
        DispatchQueue.global(qos: .userInitiated).async {
            if let wallet = self.createAccout(password: password, coin: .tomo){
                DispatchQueue.main.async {
                    let tomoWallet = TomoWallet(wallet: wallet, keyStore: self)
                    completion(.success(tomoWallet))
                }
            }else{
                DispatchQueue.main.async {
                    completion(.failure(.failedToAddAccounts))
                }
            }
        }
    }
    
    func wallet() -> [TomoWallet] {
        return [TomoWallet]()
    }
    
    func getWallet(address: String, completion: @escaping (Result<TomoWallet, TomoKeystoreError>) -> Void) {
        guard let etherAddress = EthereumAddress(string: address) else {
            completion(.failure(TomoKeystoreError.invalidAddress))
            return
        }
        print(etherAddress)
    }
}

extension Coin {
    public func derivationPath(at index: Int) -> DerivationPath {
        return DerivationPath(purpose: 44, coinType: self.rawValue, account: 0, change: 0, address: index)
    }
}



