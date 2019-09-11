//
//  TomoAPI.swift
//  Example
//
//  Created by Admin on 8/29/19.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import PromiseKit

public enum TomoWalletError: Swift.Error{
    case InvalidAmount
    case InvalidAddress
    case Insufficient(mgs: String)
   
}
extension TomoWalletError: LocalizedError{
    public var errorDescription: String?{
        switch self {
        case .InvalidAmount:
            return NSLocalizedString("Invalid Amount", comment: "")
        case .InvalidAddress:
            return NSLocalizedString("Invalid Address", comment: "")
        case .Insufficient(let mgs):
            return mgs
        }
        
    }
}



protocol TomoWallet: class {
//    // base
//    func getAddress() -> String
//    func getTomoBabance(completion: @escaping(_ balance: String?, _ error: Error?) -> Void)
//    func getTokenBalance(tokenAddress: String, completion: @escaping(_ balance: String?, _ error: Error?) -> Void)
//    func getTokenInfo(token: String, completion: @escaping(_ token: TRCToken?, _ error: Error?) -> Void)
//
//    func sendTomo(amount: String, toAddress: String, completion: @escaping(_ txHash: String?, _ error: Error?) -> Void)
//    func sendToken(tokenAddress: String, amount: String, toAddress: String, completion: @escaping(_ txHash: String?, _ error: Error?) -> Void)
//    func signPersonalMessage(message: Data, completion: @escaping(_ data: Data?, _ error: Error?) -> Void)
//    func signMessage(message: Data, completion: @escaping(_ data: Data?, _ error: Error?) -> Void)
//    func signHash(hash: Data, completion: @escaping(_ data: Data?, _ error: Error?) -> Void)
//
    
    func getTomoBabance() ->Promise<String>
    func getTokenBalance(token: TRCToken) -> Promise<String>
    func getTokenBalance(contract: String) -> Promise<String>
    func getTokenInfo(contract: String) -> Promise<TRCToken>
    
    
    
    func makeTomoTransaction(toAddress: String, amount: String) -> Promise<SignTransaction>
    func makeTokenTransaction(token: TRCToken, toAddress: String, amount: String) -> Promise<SignTransaction>
    
    func sendTransaction(signTransaction: SignTransaction) -> Promise<SentTransaction>
    func signTransaction(signTransaction: SignTransaction) -> Promise<SentTransaction>
    func signMessage(message: Data) -> Promise<Data>
    func signPersonalMessage(message: Data) -> Promise<Data>
    func signHash(hash: Data) -> Promise<Data>
    
    
}


