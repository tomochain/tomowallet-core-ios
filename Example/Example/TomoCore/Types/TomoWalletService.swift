//
//  TomoWallet.swift
//  Example
//
//  Created by Admin on 8/30/19.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import BigInt
import Result
class TomoWallet{
    fileprivate let account: Account
    fileprivate let keyStore: TomoKeystore
    private let networkProvider: NetworkProviderProtocol
    let walletInfo: TomoWalletInfo
    let type: TomoWalletType
    var address: String{
        return account.address.description
    }
  
    
    init(type: TomoWalletType, keyStore: TomoKeystore) {
        self.type = type
        self.keyStore = keyStore
        self.walletInfo = TomoWalletInfo(type: self.type)
        self.account = self.walletInfo.currentAccount
           networkProvider = NetworkProvider(server: RPCServer.TomoChainTestnet, address: account.address, provider: ApiProviderFactory.makeRPCNetworkProvider())
    }
    
}
extension TomoWallet: TomoWalletProtocol{
    func getAddress() -> String {
        return self.address
    }
    func getTomoBabance(completion: @escaping (Result<String, Error>) -> Void) {
        networkProvider.tomoBalance { (result) in
            switch result{
            case .success(let value):
                let balance = TomoNumberFormatter.full.string(from: value)
                completion(.success(balance))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func getTokenBalance(address: String, completion: @escaping (Result<String, Error>) -> Void) {
        
    }
    
    func sendTomo(amount: String, toAddress: String, completion: @escaping (Result<String, Error>) -> Void) {
        
    }
    
    func sendToken(amount: String, decimal: Int, toAddress: String, completion: @escaping (Result<String, Error>) -> Void) {
        
    }

}


