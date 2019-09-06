//
//  TomoSDK.swift
//  Example
//
//  Created by Admin on 9/3/19.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import Result

public struct TRCToken {
    let contract: EthereumAddress
    let name: String
    let symbol: String
    let decimals: Int
    let totalSupply: String
}

public enum TomoChainNetwork{
    case Mainnet
    case Testnet
}

public class WalletCore {
    private let tomoKeystoreProtocol: TomoKeystoreProtocol

    init(network: TomoChainNetwork) {
        self.tomoKeystoreProtocol = TomoKeystore(network: network)
    }
    
    func createWallet(completion: @escaping(Result<TomoWallet, TomoKeystoreError>) -> Void){
        tomoKeystoreProtocol.createWallet(completion: completion)
    }
    func getWallet(address: String, completion: @escaping(Result<TomoWallet, TomoKeystoreError>) -> Void) {
        tomoKeystoreProtocol.getWallet(address: address, completion: completion)
    }
    func getAllWallets() -> [TomoWallet] {
        return tomoKeystoreProtocol.getwallets()
    }
    
    
}