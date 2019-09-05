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
import PromiseKit

class TomoWalletService{
    fileprivate let account: Account
    fileprivate let keyStore: TomoKeystore
    private let networkProvider: NetworkProviderProtocol
    private var cacheTokens = [TRC2XToken]()
    
    private var sendTransactionsCoordinator: SendTransactionCoordinator{
        return SendTransactionCoordinator(keystore: self.keyStore, server: self.server)
    }
    let walletInfo: TomoWalletInfo
    let type: TomoWalletType
    var server: RPCServer {
        switch self.keyStore.network {
        case .Mainnet:
            return RPCServer.TomoChainMainnet
        case .Testnet:
            return RPCServer.TomoChainMainnet
        }
    }
    var address: String{
        return account.address.description
    }
    
    
    init(type: TomoWalletType, keyStore: TomoKeystore) {
        self.type = type
        self.keyStore = keyStore
        self.walletInfo = TomoWalletInfo(type: self.type)
        self.account = self.walletInfo.currentAccount
        self.networkProvider = NetworkProvider(server: RPCServer.TomoChainTestnet, address: account.address, provider: ApiProviderFactory.makeRPCNetworkProvider())
    }
    
    private func executeTransaction()
    
    
    
    
    
}

extension TomoWalletService: TomoWallet{
    func sendTomo(amount: String, toAddress: String, completion: @escaping (String?, Error?) -> Void) {
        
    }
    
    func sendToken(amount: String, decimal: Int, toAddress: String, completion: @escaping (String?, Error?) -> Void) {
        
    }
    
    func getAddress() -> String {
        return self.address
    }
    func getTomoBabance(completion: @escaping(_ balance: String?,_ error: Error?) -> Void) {
        firstly {
            networkProvider.tomoBalance()
            }.done { value in
                let balance = TomoNumberFormatter.full.string(from: value)
                completion(balance, nil)
            }.catch { error in
                completion(nil, error)
        }
    }

    func getTokenBalance(tokenAddress: String, decimals: Int?, completion: @escaping(_ balance: String?,_ error: Error?) -> Void) {
       
        
        if let decimals = decimals {
            firstly {
                networkProvider.tokenBalance(tokenAddress: tokenAddress)
                }.done { value in
                    let balance = TomoNumberFormatter.full.string(from: value, decimals: decimals)
                    completion(balance, nil)
                }.catch { error in
                    completion(nil, error)
            }
        }else{
            let p1 = networkProvider.tokenBalance(tokenAddress: tokenAddress)
            let p2 = networkProvider.tokenDecimals(tokenAddress: tokenAddress)
           

            firstly {
                when(fulfilled: p1, p2)
                }.done { value, decimals in
                    guard let decimalValue = Int(TomoNumberFormatter.full.normalString(from: decimals, decimals: 0)) else{
                        return
                    }
                    let balance = TomoNumberFormatter.full.string(from: value, decimals:decimalValue)
                    completion(balance, nil)
                }.catch { (error) in
                    completion(nil, error)
            }
        }
            
        
    }

}


