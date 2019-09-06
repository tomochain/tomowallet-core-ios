//
//  TransactionConfiguration.swift
//  Example
//
//  Created by Admin on 9/5/19.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import BigInt

public struct PreviewTransaction {
    let value: BigInt
    let account: Account
    let address: EthereumAddress?
    let contract: EthereumAddress?
    let nonce: BigInt
    let data: Data
    let gasPrice: BigInt
    let gasLimit: BigInt
    let transfer: Transfer
}

final class TransactionConfigurator {
    let account: Account
    let tomoBalance: BigInt
    let transaction: UnconfirmedTransaction
    let server: RPCServer
    var configuration: TransactionConfiguration {
        didSet {
            configurationUpdate.value = configuration
        }
    }
    var configurationUpdate: Subscribable<TransactionConfiguration> = Subscribable(nil)
    
    init(
        account: Account,
        tomoBalance: BigInt,
        transaction: UnconfirmedTransaction,
        server: RPCServer) {
    
        self.account = account
        self.transaction = transaction
        self.server = server
        self.tomoBalance = tomoBalance
        let data: Data = TransactionConfigurator.data(for: transaction, from: account.address)
        let calculatedGasLimit = transaction.gasLimit ?? TransactionConfigurator.gasLimit(for: transaction.transfer.type)
        let calculatedGasPrice = GasPriceConfiguration.max
//        let calculatedGasPrice = min(max(transaction.gasPrice ?? chainState.gasPrice ?? GasPriceConfiguration.default, GasPriceConfiguration.min), GasPriceConfiguration.max)
        
        self.configuration = TransactionConfiguration(
            gasPrice: calculatedGasPrice,
            gasLimit: calculatedGasLimit,
            data: data,
            nonce: transaction.nonce
        )
    }
    
    private static func data(for transaction: UnconfirmedTransaction, from: Address) -> Data {
        guard let to = transaction.to else { return Data() }
        switch transaction.transfer.type {
        case .tomo:
            return transaction.data ?? Data()
        case .token:
            return ERC20Encoder.encodeTransfer(to: to, tokens: transaction.value.magnitude)
        }
    }
    
    private static func gasLimit(for type: TransferType) -> BigInt {
        switch type {
        case .tomo:
            return GasLimitConfiguration.default
        case .token:
            return GasLimitConfiguration.tokenTransfer
        }
    }
    
    private static func gasPrice(for type: Transfer) -> BigInt {
        return GasPriceConfiguration.default
    }
    

    func estimateGasLimit(completion: @escaping (Result<BigInt, Error>) -> Void) {
   
    }
    
    // combine into one function
    
    func refreshGasLimit(_ gasLimit: BigInt) {
        configuration = TransactionConfiguration(
            gasPrice: configuration.gasPrice,
            gasLimit: gasLimit,
            data: configuration.data,
            nonce: configuration.nonce
        )
    }
    
    func valueToSend() -> BigInt {
        switch transaction.transfer.type {
        case .tomo:
            return transaction.value
        case .token:
            return BigInt(0)
        }
    }
    
    func previewTransaction() -> PreviewTransaction {
        return PreviewTransaction(
            value: valueToSend(),
            account: account,
            address: transaction.to,
            contract: .none,
            nonce: configuration.nonce,
            data: configuration.data,
            gasPrice: configuration.gasPrice,
            gasLimit: configuration.gasLimit,
            transfer: transaction.transfer
        )
    }
    
    var signTransaction: SignTransaction {
        let value: BigInt = {
            switch transaction.transfer.type {
            case .tomo: return valueToSend()
            case .token: return 0
            }
        }()
        let address: EthereumAddress? = {
            switch transaction.transfer.type {
            case .tomo: return transaction.to
            case .token(let token,_): return token.contract
            }
        }()
      
        let signTransaction = SignTransaction(
            value: value,
            account: account,
            to: address,
            nonce: configuration.nonce,
            data: configuration.data,
            gasPrice: configuration.gasPrice,
            gasLimit: configuration.gasLimit,
            chainID: server.chainID
        )
        
        return signTransaction
    }
    
    func update(configuration: TransactionConfiguration) {
        self.configuration = configuration
    }
    
    func balanceValidStatus() -> BalanceStatus {
        var tomoSufficient = true
        var gasSufficient = true
        var tokenSufficient = true

        let transaction = previewTransaction()
        let totalGasValue = transaction.gasPrice * transaction.gasLimit

        //We check if it is ETH or token operation.
        switch transaction.transfer.type {
        case .tomo:
            if transaction.value > tomoBalance {
                tomoSufficient = false
                gasSufficient = false
            } else {
                if totalGasValue + transaction.value > tomoBalance {
                    gasSufficient = false
                }
            }
            return .tomo(tomoSufficient: tomoSufficient, gasSufficient: gasSufficient)
        case .token(let token):
            if totalGasValue > tomoBalance {
                tomoSufficient = false
                gasSufficient = false
            }
            if transaction.value > token.tokenBalance {
                tokenSufficient = false
            }
            return .token(tokenSufficient: tokenSufficient, gasSufficient: gasSufficient)
        }
    }
}

