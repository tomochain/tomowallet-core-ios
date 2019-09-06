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
    private let noneProvider: NonceProvider
    private var cacheTokens = [TRCToken]()
    
    private lazy var sendTransactionsCoordinator: SendTransactionCoordinator = {
        return SendTransactionCoordinator(keystore: self.keyStore, server: self.server)
    }()
    let walletInfo: TomoWalletInfo
    let type: TomoWalletType
    var server: RPCServer = RPCServer.TomoChainTestnet
    var address: String{
        return account.address.description
    }
    
    
    init(type: TomoWalletType, keyStore: TomoKeystore ) {
        self.type = type
        self.keyStore = keyStore
        self.walletInfo = TomoWalletInfo(type: self.type)
        self.account = self.walletInfo.currentAccount
        self.networkProvider = NetworkProvider(server: self.server, address: account.address, provider: ApiProviderFactory.makeRPCNetworkProvider())
        self.noneProvider = GetNonceProvider(server: self.server, address: account.address, provider: ApiProviderFactory.makeRPCNetworkProvider())
    }
    
    private func executeTokenTransaction(token: TRCToken , tokenBalance: BigInt ,balance: BigInt, amount: BigInt, toAddress: EthereumAddress, completion: @escaping (String?, Error?) -> Void) {
        let transfer = Transfer(server: self.server, type: .token(token, tokenBalance: tokenBalance))
        let unconfrimTx = self.makeUnconfirmedTransaction(transfer: transfer, amount: amount, nonce: BigInt(-1), toAddress: toAddress)
        let transactionConfigurator = TransactionConfigurator(account: self.account, tomoBalance: balance, transaction: unconfrimTx, server: self.self.server)
        sendTransactionsCoordinator.send(confirmType: .signThenSend, transaction: transactionConfigurator.signTransaction) { (result) in
            switch result{
            case .success(let confirmResult):
                switch confirmResult{
                case.sentTransaction(let signTx):
                    completion(signTx.id, nil)
                case .signedTransaction(let sendTx):
                    completion(sendTx.id, nil)
                }
            case .failure(let error):
                completion(nil, error)
            }
        }
    }
    private func executeTomoTransaction(balance: BigInt, amount: BigInt, toAddress: EthereumAddress, completion: @escaping (String?, Error?) -> Void) {
        let transfer = Transfer(server: self.server, type: .tomo)
        let unconfrimTx = self.makeUnconfirmedTransaction(transfer: transfer, amount: amount, nonce: BigInt(-1), toAddress: toAddress)
        let transactionConfigurator = TransactionConfigurator(account: self.account, tomoBalance: balance, transaction: unconfrimTx, server: self.self.server)
        sendTransactionsCoordinator.send(confirmType: .signThenSend, transaction: transactionConfigurator.signTransaction) { (result) in
            switch result{
            case .success(let confirmResult):
                switch confirmResult{
                case.sentTransaction(let signTx):
                    completion(signTx.id, nil)
                    print(signTx.id)
                case .signedTransaction(let sendTx):
                    completion(sendTx.id, nil)
                }
            case .failure(let error):
                completion(nil, error)
            }
        }
    }
    private func makeUnconfirmedTransaction(transfer: Transfer, amount: BigInt, nonce: BigInt, toAddress: EthereumAddress) ->  UnconfirmedTransaction{
        return UnconfirmedTransaction(transfer: transfer,
                                      value: amount,
                                      to: toAddress,
                                      data: nil,
                                      gasLimit: nil,
                                      gasPrice: nil,
                                      nonce: nonce)
        
    }
    
    func getTokenInfo(contract: EthereumAddress) -> Promise<TRCToken> {
        return Promise{ seal in
            let p1 = networkProvider.tokenName(contract: contract.description)
            let p2 = networkProvider.tokenDecimals(contract: contract.description)
            let p3 = networkProvider.tokenSymbol(contract: contract.description)
            let p4 = networkProvider.tokenTotalSupply(contract: contract.description)
            firstly {
                when(fulfilled: p1, p2, p3, p4)
                }.done { name, decimals, symbol, totalSupply in
                    guard let decimals_value = Int(TomoNumberFormatter.full.normalString(from: decimals, decimals: 0))  else {
                        return
                    }
                    let totalSupply_value = TomoNumberFormatter.full.normalString(from: totalSupply, decimals: decimals_value)
                    let token = TRCToken(contract: contract, name: name, symbol: symbol, decimals: decimals_value, totalSupply: totalSupply_value)
                    seal.fulfill(token)
                }.catch { (error) in
                    seal.reject(error)
            }
        }
    }
 
    
}

extension TomoWalletService: TomoWallet{
    func getTokenInfo(token: String, completion: @escaping (TRCToken?, Error?) -> Void) {
        guard let contract = EthereumAddress(string: token) else {
            
            return
        }
        firstly {
            self.getTokenInfo(contract: contract)
            }.done { token in
                 completion(token, nil)
            }.catch { error in
                completion(nil, error)
        }
    }
    
    func sendTomo(amount: String, toAddress: String, completion: @escaping (String?, Error?) -> Void) {
        guard let receiptAddress = EthereumAddress(string: toAddress) else {
            completion(nil,TomoWalletError.InvalidAddress )
            return
        }
        firstly {
            networkProvider.tomoBalance()
            }.done { value in
                guard let amountValue = TomoNumberFormatter.full.number(from: amount, units: .tomo) else{
                    completion(nil, TomoWalletError.invalidAmount)
                    return
                }
                self.executeTomoTransaction(balance: value, amount: amountValue, toAddress: receiptAddress, completion: completion)
            }.catch { error in
                completion(nil, error)
        }
    }
    
    func sendToken(tokenAddress: String, amount: String, toAddress: String, completion: @escaping (String?, Error?) -> Void) {
        guard let contract = EthereumAddress(string: tokenAddress), let receive = EthereumAddress(string: toAddress) else {
            completion(nil,TomoWalletError.InvalidAddress )
            return
        }
        let p1 = self.getTokenInfo(contract: contract)
        let p2 = self.networkProvider.tokenBalance(contract: contract.description)
        let p3 = self.networkProvider.tomoBalance()
        firstly {
            when(fulfilled: p1, p2, p3)
            }.done { token , tokenBalance, tomoBalance in
                guard let amountValue = TomoNumberFormatter.full.number(from: amount, decimals: token.decimals) else{
                    completion(nil, TomoWalletError.invalidAmount)
                    return
                }
                self.executeTokenTransaction(token: token, tokenBalance: tokenBalance, balance: tomoBalance, amount: amountValue, toAddress: receive, completion: { (txHash, error) in
                    completion(txHash, error)
                })
                
            }.catch { error in
                completion(nil, error)
        }
 
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
    
    func getTokenBalance(tokenAddress: String, completion: @escaping(_ balance: String?,_ error: Error?) -> Void) {
        
        let p1 = networkProvider.tokenBalance(contract: tokenAddress)
        let p2 = networkProvider.tokenDecimals(contract: tokenAddress)
        
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


