//
//  TomoAPI.swift
//  Example
//
//  Created by Admin on 8/29/19.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
public enum TomoWalletError: LocalizedError{
    case invalidAmount
    case InvalidAddress
}


protocol TomoWallet: class {
    // base
    func getAddress() -> String
    func getTomoBabance(completion: @escaping(_ balance: String?, _ error: Error?) -> Void)
    func getTokenBalance(tokenAddress: String, completion: @escaping(_ balance: String?, _ error: Error?) -> Void)
    func sendTomo(amount: String, toAddress: String, completion: @escaping(_ txHash: String?, _ error: Error?) -> Void)
    func sendToken(tokenAddress: String, amount: String, toAddress: String, completion: @escaping(_ txHash: String?, _ error: Error?) -> Void)
    func getTokenInfo(token: String, completion: @escaping(_ token: TRCToken?, _ error: Error?) -> Void)
    
}
