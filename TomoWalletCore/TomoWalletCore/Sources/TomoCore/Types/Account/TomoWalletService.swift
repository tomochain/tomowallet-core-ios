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
    var server: RPCServer
    var address: String{
        return account.address.description
    }
    
    init(type: TomoWalletType, keyStore: TomoKeystore ) {
        switch keyStore.network {
        case .Mainnet:
            self.server = RPCServer.TomoChainMainnet
        case.Testnet:
            self.server = RPCServer.TomoChainTestnet
        }
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
        return Promise {seal in
            firstly{
                networkProvider.getTokenInfoFromScan(contract: contract.description)
                }.done({ (token) in
                    switch token.type{
                    case .TRC21:
                        firstly{
                            self.IsApplyTomoZ(contract: token.contract)
                            }.done{ (isApply) in
                                let tokenTRC21 = TRCToken(contract: token.contract, name: token.name, symbol: token.symbol, decimals: token.decimals, totalSupply: token.totalSupply, type: .TRC21(isApplyTomoZ: isApply))
                                seal.fulfill(tokenTRC21)
                                
                            }.catch({ (error) in
                                seal.reject(error)
                            })
                    default:
                        seal.fulfill(token)
                    }
                }).catch({ (error) in
                    seal.reject(error)
                })
        }
    }
    

    
    private func makeSignTransaction(tomoBalance: BigInt, tranfer: Transfer, toAddress: EthereumAddress, amount: String) -> Promise<SignTransaction>{
        return Promise {seal in
            var decimals: Int = 0
            switch tranfer.type{
            case .tomo:
                decimals = server.decimals
            case.token(let token,_):
                decimals = token.decimals
            }
            guard let amountValue = TomoNumberFormatter.full.number(from: amount, decimals: decimals) else {
                return seal.reject(TomoWalletError.InvalidAmount)
            }
            let unconfrimTx = self.makeUnconfirmedTransaction(transfer: tranfer, amount: amountValue, nonce: BigInt(-1), toAddress: toAddress)
            let transactionConfigurator = TransactionConfigurator(account: self.account, tomoBalance: tomoBalance, transaction: unconfrimTx, chainState: self.chainState, networkProvider: self.networkProvider, server: self.self.server)
            transactionConfigurator.load(completion: { (status) in
                if status.insufficientText.count > 0{
                    switch status{
                    case .token:
                        switch tranfer.type{
                        case .tomo:
                            break
                        case.token(let token,_):
                            seal.reject(TomoWalletError.Insufficient(mgs: String(format: status.insufficientText,token.symbol)))
                        }
                    case .tomo:
                        seal.reject(TomoWalletError.Insufficient(mgs: String(format: status.insufficientText, "TOMO")))
                    }
                }else{
                    seal.fulfill(transactionConfigurator.signTransaction)
                }
            })
        }
    }
    
    private func IsApplyTomoZ(contract: EthereumAddress) -> Promise<Bool>{
        return Promise{seal in
            
            
        }
    }
}

extension TomoWalletService: TomoWallet{
    
    func getAddress() -> String {
        return account.address.description
    }
    func sendTomo(toAddress: String, amount: String) -> Promise<SentTransaction> {
        return Promise{ seal in
            guard let receive = EthereumAddress(string: toAddress) else {
                return seal.reject(TomoWalletError.InvalidAddress)
            }
            firstly{
                networkProvider.tomoBalance()
                }.then({ (balance) -> Promise<SignTransaction> in
                    let transfer = Transfer(server: self.server, type: TransferType.tomo)
                    return self.makeSignTransaction(tomoBalance: balance, tranfer: transfer, toAddress: receive, amount: amount)
                }).then({ (signTX) -> Promise<SentTransaction> in
                    return self.sendTransaction(confirmType: .signThenSend, signTransaction: signTX)
                }).done({ (sentTX) in
                    seal.fulfill(sentTX)
                }).catch({ (error) in
                    seal.reject(error)
                })
        }
    }
    
    func sendToken(contract: String, toAddress: String, amount: String) -> Promise<SentTransaction> {
        
        return Promise{ seal in
            guard let contract = EthereumAddress(string: contract), let receive = EthereumAddress(string: toAddress) else {
                return seal.reject(TomoWalletError.InvalidAddress)
            }
            
            firstly {
                self.getTokenInfo(contract: contract)
                }.done { (token) in
                    let p1 = self.networkProvider.tomoBalance()
                    let p2 = self.networkProvider.tokenBalance(contract: contract.description)
                    firstly{
                        when(fulfilled: p1,p2)
                        }.then({ (tomoBalance, tokenBalance) -> Promise<SignTransaction> in
                            let transfer = Transfer(server: self.server, type: TransferType.token(token, tokenBalance: tokenBalance))
                            return self.makeSignTransaction(tomoBalance: tomoBalance, tranfer: transfer, toAddress: receive, amount: amount)
                        }).then({ (signTX) -> Promise<SentTransaction> in
                            return self.sendTransaction(confirmType: .signThenSend, signTransaction: signTX)
                        }).done({ (sentTx) in
                            seal.fulfill(sentTx)
                        }).catch({ (error) in
                            seal.reject(error)
                        })
                    
                }.catch { (error) in
                    seal.reject(error)
            }
           

        }
    }
    
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
        return Promise { seal in
            guard let contract = EthereumAddress(string: contract) else {
                return seal.reject(TomoWalletError.InvalidAddress)
            }
            firstly{
                self.getTokenInfo(contract: contract)
                }.done({ (token) in
                    seal.fulfill(token)
                }).catch({ (error) in
                    seal.reject(error)
                })
        }
    }
    
    func makeTomoTransaction(toAddress: String, amount: String) -> Promise<SignTransaction> {
        return Promise { seal in
            guard let receive = EthereumAddress(string: toAddress) else {
                return seal.reject(TomoWalletError.InvalidAddress)
            }
            
            firstly{
                networkProvider.tomoBalance()
                }.then({ (balance) -> Promise<SignTransaction> in
                    let transfer = Transfer(server: self.server, type: .tomo)
                    return self.makeSignTransaction(tomoBalance: balance, tranfer: transfer, toAddress: receive, amount: amount)
                }).done({ (signTX) in
                    seal.fulfill(signTX)
                }).catch({ (error) in
                    seal.reject(error)
                })
        }
    }
    
    func makeTokenTransaction(token: TRCToken, toAddress: String, amount: String) -> Promise<SignTransaction> {
        return Promise {seal in
            guard let receive = EthereumAddress(string: toAddress) else {
                return seal.reject(TomoWalletError.InvalidAddress)
            }
            let p1 = networkProvider.tomoBalance()
            let p2 = networkProvider.tokenBalance(contract: token.contract.description)
            firstly{
                when(fulfilled: p1, p2)
                }.then({ (balance, tokenBalance) -> Promise<SignTransaction> in
                    let transfer = Transfer.init(server: self.server, type: .token(token, tokenBalance: tokenBalance))
                    return self.makeSignTransaction(tomoBalance: balance, tranfer: transfer, toAddress: receive, amount: amount)
                }).done({ (signTX) in
                    seal.fulfill(signTX)
                }).catch({ (error) in
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
}


