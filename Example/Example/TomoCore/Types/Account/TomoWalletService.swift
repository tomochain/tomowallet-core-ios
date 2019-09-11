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
    private let chainState: ChainSate
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
        let apiProviderFactory = ApiProviderFactory.makeRPCNetworkProvider()
        self.networkProvider = NetworkProvider(server: self.server, address: account.address, provider: apiProviderFactory)
        self.noneProvider = GetNonceProvider(server: self.server, address: account.address, provider: apiProviderFactory)
        self.chainState = ChainSate(server: self.server, provider: apiProviderFactory)
        self.chainState.fetch()
    }
    
    private func executeTokenTransaction(token: TRCToken , tokenBalance: BigInt ,balance: BigInt, amount: BigInt, toAddress: EthereumAddress, completion: @escaping (String?, Error?) -> Void) {
        let transfer = Transfer(server: self.server, type: .token(token, tokenBalance: tokenBalance))
        let unconfrimTx = self.makeUnconfirmedTransaction(transfer: transfer, amount: amount, nonce: BigInt(-1), toAddress: toAddress)
        let transactionConfigurator = TransactionConfigurator(account: self.account, tomoBalance: balance, transaction: unconfrimTx, chainState: self.chainState, networkProvider: self.networkProvider, server: self.self.server)
        sendTransactionsCoordinator.send(confirmType: .signThenSend, transaction: transactionConfigurator.signTransaction, for: self.account) { (result) in
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
        let transactionConfigurator = TransactionConfigurator(account: self.account, tomoBalance: balance, transaction: unconfrimTx, chainState: self.chainState, networkProvider: self.networkProvider, server: self.self.server)
        sendTransactionsCoordinator.send(confirmType: .signThenSend, transaction: transactionConfigurator.signTransaction, for: self.account) { (result) in
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
    private func makeUnconfirmedTransaction(transfer: Transfer, amount: BigInt, nonce: BigInt, toAddress: EthereumAddress) ->  UnconfirmedTransaction{
        return UnconfirmedTransaction(transfer: transfer,
                                      value: amount,
                                      to: toAddress,
                                      data: nil,
                                      gasLimit: nil,
                                      gasPrice: nil,
                                      nonce: nonce)
        
    }
    
    private func sendTransaction(confirmType: ConfirmType, signTransaction:SignTransaction) -> Promise<SentTransaction>{
        return Promise { seal in
            sendTransactionsCoordinator.send(confirmType: .signThenSend, transaction: signTransaction, for: self.account) { (result) in
                switch result{
                case .success(let confirmResult):
                    switch confirmResult{
                    case.sentTransaction(let signTx):
                        seal.fulfill(signTx)
                    case .signedTransaction(let sendTx):
                        seal.fulfill(sendTx)
                    }
                case .failure(let error):
                    seal.reject(error)
                }
            }
        }
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
                    let token = TRCToken(contract: contract, name: name, symbol: symbol, decimals: decimals_value, totalSupply: totalSupply_value, type: .Unkwown)
                    seal.fulfill(token)
                }.catch { (error) in
                    seal.reject(error)
            }
        }
    }
    
    private func makeSignTransaction(tomoBalance: BigInt, tranfer: Transfer, toAddress: EthereumAddress, amount: BigInt) -> Promise<SignTransaction>{
        return Promise {seal in
            let unconfrimTx = self.makeUnconfirmedTransaction(transfer: tranfer, amount: amount, nonce: BigInt(-1), toAddress: toAddress)
            let transactionConfigurator = TransactionConfigurator(account: self.account, tomoBalance: tomoBalance, transaction: unconfrimTx, chainState: self.chainState, networkProvider: self.networkProvider, server: self.self.server)
            transactionConfigurator.load(completion: { (status) in
                if status.insufficientText.count > 0{
                    switch status{
                    case .token:
                        seal.reject(TomoWalletError.Insufficient(mgs: String(format: "status.insufficientText")))
                    case .tomo:
                        seal.reject(TomoWalletError.Insufficient(mgs: String(format: status.insufficientText, "TOMO")))
                    }
                }else{
                    seal.fulfill(transactionConfigurator.signTransaction)
                }
            })
        }
    }
}

extension TomoWalletService: TomoWallet{
    func getTomoBabance() -> Promise<String> {
        return Promise {seal in
            firstly {
                networkProvider.tomoBalance()
                }.done { value in
                    let balance = TomoNumberFormatter.full.string(from: value)
                    seal.fulfill(balance)
                }.catch { error in
                    seal.reject(error)
            }
        }
    }
    func getTokenBalance(contract: String) -> Promise<String>{
        return Promise{ seal in
            let p1 = networkProvider.tokenBalance(contract: contract)
            let p2 = networkProvider.tokenDecimals(contract: contract)
            
            firstly {
                when(fulfilled: p1, p2)
                }.done { value, decimals in
                    guard let decimalValue = Int(TomoNumberFormatter.full.normalString(from: decimals, decimals: 0)) else{
                        return
                    }
                    let balance = TomoNumberFormatter.full.string(from: value, decimals:decimalValue)
                    seal.fulfill(balance)
                }.catch { (error) in
                    seal.reject(error)
            }
        }
    }
    
    func getTokenBalance(token: TRCToken) -> Promise<String> {
        return Promise{ seal in
            firstly {
                networkProvider.tokenBalance(contract: token.contract.description)
                }.done { value in
                    let balance = TomoNumberFormatter.full.string(from: value, decimals:token.decimals)
                    seal.fulfill(balance)
                }.catch { (error) in
                    seal.reject(error)
            }
        }
    }
    
    
    func getTokenInfo(contract: String) -> Promise<TRCToken> {
        return Promise {seal in
            
        }
    }
    
    func makeTomoTransaction(toAddress: String, amount: String) -> Promise<SignTransaction> {
        return Promise { seal in
            guard let receive = EthereumAddress(string: toAddress) else {
                return seal.reject(TomoWalletError.InvalidAddress)
            }
            guard let amountValue = TomoNumberFormatter.full.number(from: amount) else{
                return seal.reject(TomoWalletError.InvalidAmount)
            }
       
            firstly {
                networkProvider.tomoBalance()
                }.done { tomoBalance in
                    let transfer = Transfer(server: self.server, type: .tomo)
                    firstly {
                        self.makeSignTransaction(tomoBalance: tomoBalance, tranfer: transfer, toAddress: receive, amount: amountValue)
                        }.done({ (signTransaction) in
                            seal.fulfill(signTransaction)
                        }).catch{ error in
                            seal.reject(error)
                            
                    }
                }.catch { error in
                    seal.reject(error)
            }
            
        }
    }
    
    func makeTokenTransaction(token: TRCToken, toAddress: String, amount: String) -> Promise<SignTransaction> {
        return Promise {seal in
            guard let receive = EthereumAddress(string: toAddress) else {
                return seal.reject(TomoWalletError.InvalidAddress)
            }
            guard let amountValue = TomoNumberFormatter.full.number(from: amount, decimals: token.decimals) else{
                return seal.reject(TomoWalletError.InvalidAmount)
            }
            
            let p1 = networkProvider.tomoBalance()
            let p2 = networkProvider.tokenBalance(contract: token.contract.description)
            firstly{
                when(fulfilled: p1, p2)
                }.done{ tomoBalance,tokenBabance in
                    let transfer = Transfer.init(server: self.server, type: .token(token, tokenBalance: tomoBalance))
                    firstly{
                        self.makeSignTransaction(tomoBalance: tomoBalance, tranfer: transfer, toAddress: receive , amount: amountValue)
                        }.done({ (signTransaction) in
                            seal.fulfill(signTransaction)
                        }).catch({ (error) in
                            seal.reject(error)
                        })
                }.catch({ (error) in
                    seal.reject(error)
                })
        }
    }
    
    func sendTransaction(signTransaction: SignTransaction) -> Promise<SentTransaction> {
        return Promise {seal in
            self.sendTransactionsCoordinator.send(confirmType: .signThenSend, transaction: signTransaction, for: self.account) { (result) in
                switch result{
                case .success(let confirmResult):
                    switch confirmResult{
                    case.sentTransaction(let sentTx):
                        seal.fulfill(sentTx)
                    case .signedTransaction:
                        break
                    }
                case .failure(let error):
                    seal.reject(error)
                }
            }
        }
    }
    
    func signTransaction(signTransaction: SignTransaction) -> Promise<SentTransaction> {
        return Promise {seal in
            self.sendTransactionsCoordinator.send(confirmType: .sign, transaction: signTransaction, for: self.account) { (result) in
                switch result{
                case .success(let confirmResult):
                    switch confirmResult{
                    case.sentTransaction:
                        break
                    case .signedTransaction(let signTx):
                        seal.fulfill(signTx)
                    }
                case .failure(let error):
                    seal.reject(error)
                }
            }
        }
    }
    
    func signMessage(message: Data) -> Promise<Data> {
        return Promise { seal in
            let result = keyStore.signMessage(message, for: self.account)
            switch result {
            case .success(let data):
                seal.fulfill(data)
            case .failure(let error):
                seal.reject(error)
            }
        }
    }
    
    func signPersonalMessage(message: Data) -> Promise<Data> {
        return Promise {seal in
            let result = keyStore.signPersonalMessage(message, for: self.account)
            switch result{
            case .success(let data):
                seal.fulfill(data)
            case.failure(let error):
                seal.reject(error)
            }
        }
    }
    
    func signHash(hash: Data) -> Promise<Data> {
        return Promise {seal in
            let result = keyStore.signHash(hash, for: self.account)
            switch result{
            case .success(let data):
                seal.fulfill(data)
            case.failure(let error):
                seal.reject(error)
            }
        }
    }
    
    
//    func makeTomoTransaction(toAddress: String, amount: String) -> Promise<SignTransaction> {
//        return Promise { seal in
//            guard let toAddress = EthereumAddress(string: toAddress) else {
//                return seal.reject(TomoWalletError.InvalidAddress)
//            }
//            guard let amountValue = TomoNumberFormatter.full.number(from: amount) else{
//                return seal.reject(TomoWalletError.InvalidAmount)
//            }
//            firstly {
//                networkProvider.tomoBalance()
//                }.done { value in
//                    let transfer = Transfer(server: self.server, type: .tomo)
//                    let unconfrimTx = self.makeUnconfirmedTransaction(transfer: transfer, amount: amountValue, nonce: BigInt(-1), toAddress: toAddress)
//                    let transactionConfigurator = TransactionConfigurator(account: self.account, tomoBalance: value, transaction: unconfrimTx, chainState: self.chainState, networkProvider: self.networkProvider, server: self.self.server)
//                    transactionConfigurator.load(completion: { (status) in
//                        if status.insufficientText.count > 0{
//                            switch status{
//                            case .token(let tokenSufficient, let gasSufficient):
//                                seal.reject(TomoWalletError.Insufficient(mgs: String(format: "status.insufficientText")))
//                            case .tomo(let tomoSufficient, let gasSufficient):
//                                seal.reject(TomoWalletError.Insufficient(mgs: String(format: status.insufficientText, "TOMO")))
//                            }
//                        }else{
//                            seal.fulfill(transactionConfigurator.signTransaction)
//                        }
//
//
//                    })
//
//                }.catch { error in
//                    seal.reject(error)
//            }
//
//        }
//
//    }
//
//    func sendRawTransaction(tx: SignTransaction) -> Promise<SentTransaction> {
//
//        return self.sendTransaction(confirmType: .signThenSend, signTransaction: tx)
//    }
//
//
//
//    func signPersonalMessage(message: Data, completion: @escaping (Data?, Error?) -> Void) {
//        
//    }
//
//    func signMessage(message: Data, completion: @escaping (Data?, Error?) -> Void) {
//
//    }
//
//    func signHash(hash: Data, completion: @escaping (Data?, Error?) -> Void) {
//
//    }
//
//    func sendTransaction(signTransaction: SignTransaction, completion: @escaping (SentTransaction?, Error?) -> Void) {
//
//    }
//
//    func getTokenInfo(token: String, completion: @escaping (TRCToken?, Error?) -> Void) {
//        guard let contract = EthereumAddress(string: token) else {
//
//            return
//        }
//        firstly {
//            self.getTokenInfo(contract: contract)
//            }.done { token in
//                 completion(token, nil)
//            }.catch { error in
//                completion(nil, error)
//        }
//    }
//
//    func sendTomo(amount: String, toAddress: String, completion: @escaping (String?, Error?) -> Void) {
//        guard let receiptAddress = EthereumAddress(string: toAddress) else {
//            completion(nil,TomoWalletError.InvalidAddress )
//            return
//        }
//        firstly {
//            networkProvider.tomoBalance()
//            }.done { value in
//                guard let amountValue = TomoNumberFormatter.full.number(from: amount, units: .tomo) else{
//                    completion(nil, TomoWalletError.InvalidAmount)
//                    return
//                }
//                self.executeTomoTransaction(balance: value, amount: amountValue, toAddress: receiptAddress, completion: completion)
//            }.catch { error in
//                completion(nil, error)
//        }
//    }
//
//    func sendToken(tokenAddress: String, amount: String, toAddress: String, completion: @escaping (String?, Error?) -> Void) {
//        guard let contract = EthereumAddress(string: tokenAddress), let receive = EthereumAddress(string: toAddress) else {
//            completion(nil,TomoWalletError.InvalidAddress )
//            return
//        }
//        let p1 = self.getTokenInfo(contract: contract)
//        let p2 = self.networkProvider.tokenBalance(contract: contract.description)
//        let p3 = self.networkProvider.tomoBalance()
//        firstly {
//            when(fulfilled: p1, p2, p3)
//            }.done { token , tokenBalance, tomoBalance in
//                guard let amountValue = TomoNumberFormatter.full.number(from: amount, decimals: token.decimals) else{
//                    completion(nil, TomoWalletError.InvalidAmount)
//                    return
//                }
//                self.executeTokenTransaction(token: token, tokenBalance: tokenBalance, balance: tomoBalance, amount: amountValue, toAddress: receive, completion: { (txHash, error) in
//                    completion(txHash, error)
//                })
//
//            }.catch { error in
//                completion(nil, error)
//        }
//
//    }
//
//    func getAddress() -> String {
//        return self.address
//    }
//    func getTomoBabance(completion: @escaping(_ balance: String?,_ error: Error?) -> Void) {
//        firstly {
//            networkProvider.tomoBalance()
//            }.done { value in
//                let balance = TomoNumberFormatter.full.string(from: value)
//                completion(balance, nil)
//            }.catch { error in
//                completion(nil, error)
//        }
//    }
//
//    func getTokenBalance(tokenAddress: String, completion: @escaping(_ balance: String?,_ error: Error?) -> Void) {
//
//        let p1 = networkProvider.tokenBalance(contract: tokenAddress)
//        let p2 = networkProvider.tokenDecimals(contract: tokenAddress)
//
//        firstly {
//            when(fulfilled: p1, p2)
//            }.done { value, decimals in
//                guard let decimalValue = Int(TomoNumberFormatter.full.normalString(from: decimals, decimals: 0)) else{
//                    return
//                }
//                let balance = TomoNumberFormatter.full.string(from: value, decimals:decimalValue)
//                completion(balance, nil)
//            }.catch { (error) in
//                completion(nil, error)
//        }
//    }
    
}


