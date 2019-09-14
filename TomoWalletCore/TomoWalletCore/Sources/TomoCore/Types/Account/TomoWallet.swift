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
    case InvalidToken
    case Insufficient(mgs: String)
    case ErrorFromServer(msg: String)
   
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
        case .InvalidToken:
            return NSLocalizedString("Invalid Token", comment: "")
        case .ErrorFromServer(let msg):
            return msg
        }
    }
}



public protocol TomoWallet: class{
    func getAddress() -> String
    
    func sendTomo(toAddress: String, amount:String) -> Promise<SentTransaction>
    func sendToken(contract: String, toAddress: String, amount: String) -> Promise<SentTransaction>
    
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

