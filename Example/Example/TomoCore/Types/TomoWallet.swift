//
//  TomoWallet.swift
//  Example
//
//  Created by Admin on 8/30/19.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import BigInt
class TomoWallet{
    fileprivate let wallet: Wallet
    fileprivate let account: Account
    fileprivate let keyStore: TomoKeystore
    
    init(wallet: Wallet, keyStore: TomoKeystore) {
        self.wallet = wallet
        self.account = wallet.accounts.first!
        self.keyStore = keyStore
    }
    
  
    
}
