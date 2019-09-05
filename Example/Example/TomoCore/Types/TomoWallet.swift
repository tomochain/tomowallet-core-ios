//
//  TomoAPI.swift
//  Example
//
//  Created by Admin on 8/29/19.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import Result

protocol TomoWallet: class {
    // base
    func getAddress() -> String
    func getTomoBabance(completion: @escaping(Result<String,Error>) -> Void)
    func getTokenBalance(address: String, completion: @escaping(Result<String,Error>) -> Void)
    func sendTomo(amount: String, toAddress: String, completion: @escaping(Result<String,Error>) -> Void)
    func sendToken(amount: String, decimal: Int, toAddress: String, completion: @escaping(Result<String,Error>) -> Void)
    
    // extentions
//    func signPersonalMessage(_ data: Data, completion: @escaping(Result<Data, Error>) -> Void)
//    func signMessage(_ message: Data, completion: @escaping(Result<Data, Error>) -> Void)
//    func signHash(_ hash: Data, completion: @escaping(Result<Data, Error>) -> Void )
//    func signTransaction(_ signTransaction: SignTransaction, completion: @escaping(Result<Data,Error>) -> Void)
//    func signTypedMessage(_ datas: [EthTypedData] ,completion: @escaping(Result<Data,Error>) -> Void)
    
}
