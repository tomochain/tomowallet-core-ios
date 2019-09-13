//
//  TomoKeystoreError.swift
//  Example
//
//  Created by Admin on 8/29/19.
//  Copyright © 2019 Admin. All rights reserved.
//



import Foundation
enum TomoKeystoreError: Swift.Error{
    case failedToDeleteAccount
    case failedToDecryptKey
    case failedToImport(Error)
    case duplicateAccount
    case failedToSignTransaction
    case failedToUpdatePassword
    case failedToCreateWallet
    case failedToImportPrivateKey
    case failedToImportMnemonic
    case failedToParseJSON
    case accountNotFound
    case failedToSignMessage
    case failedToSignTypedMessage
    case failedToExportPrivateKey
    case invalidMnemonicPhrase
    case failedToAddAccounts
    // tomoAdd
    case invalidMnemonicPhraseorPrivatekey
    case invalidAddress
    
}

extension TomoKeystoreError: LocalizedError{
    public var errorDescription: String?{
        switch self {
        case .failedToDeleteAccount:
            return NSLocalizedString("Failed to delete account", comment: "")
        case .failedToDecryptKey:
            return NSLocalizedString("Could not decrypt key with given passphrase", comment: "")
        case .failedToImport(let error):
            return error.localizedDescription
        case .duplicateAccount:
            return NSLocalizedString("You already added this address to wallets", comment: "")
        case .failedToSignTransaction:
            return NSLocalizedString("Failed to sign transaction", comment: "")
        case .failedToUpdatePassword:
            return NSLocalizedString("Failed to update password", comment: "")
        case .failedToCreateWallet:
            return NSLocalizedString("Failed to create wallet", comment: "")
        case .failedToImportPrivateKey:
            return NSLocalizedString("Failed to import private key", comment: "")
        case .failedToImportMnemonic:
            return NSLocalizedString("Failed to import Mnemonic", comment: "")
        case .failedToParseJSON:
            return NSLocalizedString("Failed to parse key JSON", comment: "")
        case .accountNotFound:
            return NSLocalizedString("Account not found", comment: "")
        case .failedToSignMessage:
            return NSLocalizedString("Failed to sign message", comment: "")
        case .failedToSignTypedMessage:
            return NSLocalizedString("Failed to sign typed message", comment: "")
        case .failedToExportPrivateKey:
            return NSLocalizedString("Failed to export private key", comment: "")
        case .invalidMnemonicPhrase:
            return NSLocalizedString("Invalid mnemonic phrase", comment: "")
        case .failedToAddAccounts:
            return NSLocalizedString("Faield to add accounts", comment: "")
        case .invalidMnemonicPhraseorPrivatekey:
            return NSLocalizedString("Invalid mnemonic phrase or privatekey", comment: "")
        case .invalidAddress:
            return NSLocalizedString("Invalid Address", comment: "")
        }
    }
   
}
