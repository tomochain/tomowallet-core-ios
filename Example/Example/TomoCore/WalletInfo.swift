//
//  TomoWalletExtention.swift
//  Example
//
//  Created by Admin on 8/30/19.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
class TomoWalletExtention: TomoWallet {
    fileprivate let wallet: Wallet
    fileprivate let account: Account
    
    init(wallet: Wallet) {
        self.wallet = wallet
        self.account = wallet.accounts.first!
    }
    
    //    // Public
    //    public func getAddress() -> String{
    //        return self.account.address.description
    //    }
    //    public func getBalance(completion:@escaping(_ balance: Double) -> ()){
    //
    //    }
    
}
