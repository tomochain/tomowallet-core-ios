//
//  TomoWalletExtention.swift
//  Example
//
//  Created by Admin on 8/30/19.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation

struct TomoWalletInfo {
    let type: TomoWalletType
    let info: TomoWalletObject
    var address: Address {
        switch type {
        case .privateKey, .hd:
            return currentAccount.address
        case .address( _, let address):
            return address
        }
    }
    var coin: Coin?{
        switch type {
        case .privateKey, .hd:
            guard let account = currentAccount,
                let coin = Coin(rawValue: account.derivationPath.coinType) else {
                    return .none
            }
            return coin
        case .address(let coin, _):
            return coin
        }
    }
    var multiWallet: Bool {
        return self.accounts.count > 1
    }
    var mainWallet: Bool{
        return info.mainWallet
    }
    
    var accounts: [Account]{
        switch type {
        case .privateKey(let account), .hd(let account):
            return account.accounts
        case .address(let coin, let address):
            return [
                Account(wallet: .none, address: address, derivationPath: coin.derivationPath(at: 0))
            ]
        }
    }
    
    var currentAccount: Account!{
        switch type {
        case .privateKey, .hd :
            return accounts.first
        case .address(let coin, let address):
            return Account(wallet: .none, address: address, derivationPath: coin.derivationPath(at: 0))
        }
    }
    var currentWallet: Wallet?{
        switch type {
        case .privateKey(let wallet), .hd(let wallet):
            return wallet
        case .address:
            return .none
        }
    }
    
    var isWatch: Bool{
        switch type {
        case .privateKey,.hd:
            return false
        case .address:
            return true
        }
    }
    init( type: TomoWalletType, info: TomoWalletObject? = .none) {
        self.type = type;
        self.info = info ?? TomoWalletObject.from(type)
    }
    
    var description: String {
        return type.description
    }
    
    var completedBackup: Bool{
        switch type {
        case .hd:
            return info.completedBackup
        default:
            return true
        }
    }
    
}
extension TomoWalletInfo: Equatable{
    static func == (lhs: TomoWalletInfo, rhs: TomoWalletInfo) -> Bool {
        return lhs.type.description == rhs.type.description
    }
}

//extension WalletInfo {
//    static func format(value: String, server: RPCServer) -> String {
//        return "\(value) \(server.symbol)"
//    }
//}
