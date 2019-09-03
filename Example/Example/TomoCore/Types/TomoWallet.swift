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
    func getAddress() -> String{
        return account.address.description
    }
    func getBalance(completion:@escaping(Result<String, Error>) -> Void){
        
    }
    
    func getBalanceForToken(address: String, completion:@escaping(Result<String, Error>) -> Void){
        
    }
    func send(amount: String, toAddress: String, Data: Data?, wattingToConfrim: @escaping(Result<String, Error>) -> Void ,completion:@escaping(Result<Bool, Error>?) -> Void){
        
    }
    func senTRC20(amount: String, tokenAddress: String, toAddress: String, compmletion:@escaping()->()){
        
    }
    
    
    
    

}
