//
//  TomoAPI.swift
//  Example
//
//  Created by Admin on 8/29/19.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation


protocol TomoWallet: class {
    // base
    func getAddress() -> String
    func getTomoBabance(completion: @escaping(_ balance: String?, _ error: Error?) -> Void)
    func getTokenBalance(tokenAddress: String, decimals: Int?, completion: @escaping(_ balance: String?, _ error: Error?) -> Void)
    func sendTomo(amount: String, toAddress: String, completion: @escaping(_ txHash: String?, _ error: Error?) -> Void)
    func sendToken(amount: String, decimal: Int, toAddress: String, completion: @escaping(_ txHash: String?, _ error: Error?) -> Void)
    
    // extentions
//    func signPersonalMessage(_ data: Data, completion: @escaping(Result<Data, Error>) -> Void)
//    func signMessage(_ message: Data, completion: @escaping(Result<Data, Error>) -> Void)
//    func signHash(_ hash: Data, completion: @escaping(Result<Data, Error>) -> Void )
//    func signTransaction(_ signTransaction: SignTransaction, completion: @escaping(Result<Data,Error>) -> Void)
//    func signTypedMessage(_ datas: [EthTypedData] ,completion: @escaping(Result<Data,Error>) -> Void)
    
}
