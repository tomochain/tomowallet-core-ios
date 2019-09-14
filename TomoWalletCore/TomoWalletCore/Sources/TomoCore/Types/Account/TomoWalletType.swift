//
//  WalletType.swift
//  Example
//
//  Created by Admin on 8/31/19.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation

enum TomoWalletType {
    struct Keys {
        static let walletPrivateKey = "wallet-private-key"
        static let walletHD = "wallet-hd-wallet"
        static let address = "wallet-address"
    }
    case privateKey(Wallet)
    case hd(Wallet)
    case address(Coin, EthereumAddress)
    var description: String{
        switch self {
        case .privateKey(let account):
            return Keys.walletPrivateKey + account.identifier;
        case .hd(let account):
            return Keys.walletHD + account.identifier
        case .address(let coin, let address):
            return Keys.address + "\(coin.rawValue)" + "-" + "\(address.description)"
        }
    }
}
// compare
extension TomoWalletType: Equatable{
    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    static func == (lhs: TomoWalletType, rhs: TomoWalletType) -> Bool {
        switch (lhs, rhs) {
        case (let .privateKey(lhs), let .privateKey(rhs)):
            return lhs == rhs
        case (let .hd(lhs), let .hd(rhs)):
            return lhs == rhs
        case (let .address(lhs), let .address(rhs)):
            return lhs == rhs
        case (.privateKey, _),
             (.hd, _),
             (.address, _):
            return false
        }
    }
}

