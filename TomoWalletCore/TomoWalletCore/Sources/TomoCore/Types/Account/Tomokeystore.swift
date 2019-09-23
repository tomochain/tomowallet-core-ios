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
import Result
import BigInt

public enum WalletInfoField {
    case name(String)
    case backup(Bool)
}

enum ImportType{
    case privatekey(privateKey: String)
    case mnemonic (words: [String], derivationPath: DerivationPath)
    case address (address: EthereumAddress)
}
class TomoKeystore {
    
    var hasWallets: Bool{
        return true
    }
    
    
    public static let keychainKeyPrefix = "tomowallet"
    let keysDirectory: URL
    let keyStore: KeyStore
    
    // set keychain save password lock account
    private let keychain: KeychainSwift
    private let defaultKeychainAccess: KeychainSwiftAccessOptions = .accessibleWhenUnlockedThisDeviceOnly
    
    // StoreWalletInfo
    private let storage: TomoWalletStorage
    
    
    var wallets: [TomoWalletService] {
        
        return [
            keyStore.wallets.filter{
                !$0.accounts.isEmpty
                }.compactMap{
                    switch $0.type{
                    case WalletType.encryptedKey:
                        let type = TomoWalletType.privateKey($0)
                        return TomoWalletService(type: type, keyStore: self)
                    case WalletType.hierarchicalDeterministicWallet:
                        let type = TomoWalletType.hd($0)
                        return TomoWalletService(type: type, keyStore: self)
                    }
                },
            storage.addresses.compactMap{
                 guard let address = $0.address else { return .none }
                let type = TomoWalletType.address(.tomo, address)
                return TomoWalletService(type: type, keyStore: self)
            },
            ].flatMap { $0 }.sorted(by: { $0.walletInfo.info.createdAt < $1.walletInfo.info.createdAt })
    }
    
    let network: TomoChainNetwork
    
    init(dataDirectory: URL, network: TomoChainNetwork) {
        // keystore init
        keysDirectory = dataDirectory.appendingPathComponent("keystore")
        keyStore = try! KeyStore(keyDirectory: keysDirectory)
        // keychain init
        keychain = KeychainSwift(keyPrefix: Constants.keychainKeyPrefix)
        storage = TomoWalletStorage(dataDirectory: dataDirectory)
        self.network = network
    }
    

    
    func createAccout( password: String, coin: Coin) -> Wallet?  {
        
        do {
            let wallet = try self.keyStore.createWallet(password: password, derivationPaths: [coin.derivationPath(at: 0)])
            // check not save password to keychain
            if setPassword(password, for: wallet){
                self.store(object: TomoWalletObject.from(TomoWalletType.hd(wallet)), fields: [WalletInfoField.backup(false)])
                return wallet
            }else{
                try! FileManager().removeItem(at: wallet.keyURL)
                return .none
            }
        } catch {
            return .none
        }
        
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
        for field in fields {
            switch field {
            case .name(let name):
                object.name = name
            case .backup(let completedBackup):
                object.completedBackup = completedBackup
            }
        }
        storage.storeWalletInfo(walletObject: object)
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
    
    func exportPrivateKey(account: Account, completion: @escaping (Result<Data, TomoKeystoreError>) -> Void) {
        guard let password = getPassword(for: account.wallet!) else{
            return completion(.failure(TomoKeystoreError.accountNotFound))
        }
        DispatchQueue.global(qos: .userInitiated).async {
            do{
                let privatekey = try account.privateKey(password: password).data
                DispatchQueue.main.async {
                    completion(.success(privatekey))
                }
            }catch{
                DispatchQueue.main.async {
                    completion(.failure(TomoKeystoreError.accountNotFound))
                }
            }
        }
        
    }
    
    func exportMnemonic(wallet: Wallet, completion: @escaping (Result<[String], TomoKeystoreError>) -> Void) {
        guard let password = getPassword(for: wallet) else {
            return completion(.failure(TomoKeystoreError.accountNotFound))
        }
        DispatchQueue.global(qos: .unspecified).async {
            do{
                let mnemonic = try self.keyStore.exportMnemonic(wallet: wallet, password: password)
                let words = mnemonic.components(separatedBy: " ")
                DispatchQueue.main.async {
                    completion(.success(words))
                }
                
            }catch{
                DispatchQueue.main.async {
                    completion(.failure(TomoKeystoreError.accountNotFound))
                }
            }
        }
    }
    
    func delete(wallet: Wallet) -> Result<Void, TomoKeystoreError> {
        guard let password = getPassword(for: wallet) else {
            return .failure(TomoKeystoreError.failedToDeleteAccount)
        }
        do{
            try keyStore.delete(wallet: wallet, password: password)
            return .success(())
            
        }catch{
            return .failure(TomoKeystoreError.failedToDeleteAccount)
        }
    }
    
    //MARK: - Import Wallet
    
    func importWallet(type: ImportType, coin: Coin, completion: @escaping (Result <TomoWallet, TomoKeystoreError>) -> Void) {
        let newPassword = PasswordGenerator.generateRandom()
        switch type {
        case .privatekey(let privatekey):
            let privateKeyData = PrivateKey(data: Data(hexString: privatekey)!)!
            DispatchQueue.global(qos: .userInitiated).async {
                do{
                    let wallet = try self.keyStore.import(privateKey: privateKeyData, password: newPassword, coin: coin)
                    // check not save password to keychain
                    if self.setPassword(newPassword, for: wallet){
                        DispatchQueue.main.async {
                            self.store(object: TomoWalletObject.from(TomoWalletType.privateKey(wallet)), fields: [WalletInfoField.backup(true)])
                            completion(.success(TomoWalletService(type: TomoWalletType.privateKey(wallet), keyStore: self)))
                        }
                    }else{
                        try! FileManager().removeItem(at: wallet.keyURL)
                        DispatchQueue.main.async {
                            completion(.failure(TomoKeystoreError.failedToImportPrivateKey))
                        }
                    }
                }catch{
                    DispatchQueue.main.async {
                        completion(.failure(TomoKeystoreError.failedToImportPrivateKey))
                    }
                    
                }
            }
        case .mnemonic(let words, let derivationPath):
            let mnemonicString = words.map{ String($0)}.joined(separator: " ")
            if !Crypto.isValid(mnemonic: mnemonicString){
                return completion(.failure(TomoKeystoreError.invalidMnemonicPhrase))
            }
            do {
                let wallet = try keyStore.import(mnemonic: mnemonicString, encryptPassword: newPassword, derivationPath: derivationPath)
                // check not save password to keychain
                if self.setPassword(newPassword, for: wallet){
                    DispatchQueue.main.async {
                        self.store(object: TomoWalletObject.from(TomoWalletType.hd(wallet)), fields: [WalletInfoField.backup(true)])
                        completion(.success(TomoWalletService(type: TomoWalletType.hd(wallet), keyStore: self)))
                    }
                }else{
                    try! FileManager().removeItem(at: wallet.keyURL)
                    DispatchQueue.main.async {
                        return completion(.failure(TomoKeystoreError.failedToImportMnemonic))
                    }
                }
            }catch(let error){
                
                DispatchQueue.main.async {
                    return completion(.failure(TomoKeystoreError.failedToImport(error)))
                }
            }
            
        case .address(let address):
            let watchWallet = WalletAddress(coin: coin, address: address)
            let wallet = storage.addresses.filter { $0.addressString.lowercased() == watchWallet.addressString.lowercased()}.first
            if wallet != nil{
                completion(.failure(TomoKeystoreError.duplicateAccount))
            }else{
                storage.store(address: watchWallet)
                completion(.success(TomoWalletService(type: TomoWalletType.address(Coin.tomo, address), keyStore: self)))
            }
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
    
    func importWallet(hexPrivateKey: String, completion: @escaping (Result<TomoWallet, TomoKeystoreError>) -> Void) {
        
        if PrivateKey.isValid(data: Data(hexString: hexPrivateKey) ?? Data()){
            self.importWallet(type: ImportType.privatekey(privateKey: hexPrivateKey), coin: .tomo, completion: completion)
        }else{
            completion(.failure(TomoKeystoreError.invalidMnemonicPhraseorPrivatekey))
        }
        
    }
    
    func importWallet(words: String, completion: @escaping (Result<TomoWallet, TomoKeystoreError>) -> Void) {
        let newwords = words.components(separatedBy: " ")
        let coin = Coin.tomo
        if newwords.count == 12{
            self.importWallet(type: ImportType.mnemonic(words: newwords, derivationPath: coin.derivationPath(at: 0)), coin: coin, completion: completion)
        }else{
            completion(.failure(TomoKeystoreError.invalidMnemonicPhraseorPrivatekey))
        }
    }
    
    func importAddressOnly(address: String, completion: @escaping (Result<TomoWallet, TomoKeystoreError>) -> Void) {
        if let validAddress = EthereumAddress(string: address){
            self.importWallet(type: ImportType.address(address: validAddress), coin: .tomo, completion: completion)
        }else{
            completion(.failure(TomoKeystoreError.invalidAddress))
        }
    }
    
}

extension Coin {
    func derivationPath(at index: Int) -> DerivationPath {
        return DerivationPath(purpose: 44, coinType: self.rawValue, account: 0, change: 0, address: index)
    }
}



