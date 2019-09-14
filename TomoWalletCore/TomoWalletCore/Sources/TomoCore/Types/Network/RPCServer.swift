//
//  RPCServer.swift
//  Example
//
//  Created by Admin on 9/3/19.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
enum RPCServer {
    case TomoChainMainnet
    case TomoChainTestnet
    
    var id: String {
        switch self {
        case .TomoChainMainnet: return "tomochainmainnet"
        case .TomoChainTestnet: return "tomochaintestnet"
        }
    }
    
    var chainID: Int {
        switch self {
        case .TomoChainMainnet: return 88
        case .TomoChainTestnet: return 89
        }
    }
    
    var priceID: Address {
    return EthereumAddress(string: "0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee")!
    }
    // block frequency for chain
    var blockTime: Int{
        return 2
    }

    var decimals: Int {
        return 18
    }
    
    var rpcURL: URL {
        let urlString: String = {
            switch self {
                case .TomoChainMainnet: return "https://rpc.tomochain.com/"
                case .TomoChainTestnet: return "https://testnet.tomochain.com/"
            }
        }()
        return URL(string: urlString)!
    }
    
    var coin: Coin {
        return Coin.tomo
    }
    
    var issuerContract: String{
        switch self {
        case .TomoChainMainnet:
            return "0x8c0faeb5c6bed2129b8674f262fd45c4e9468bee"
        case .TomoChainTestnet:
            return "0x7081C72c9DC44686C7B7EAB1d338EA137Fa9f0D3"
        }
    }
    
    var URLScan: URL{
        
        let urlString: String = {
            switch self {
            case .TomoChainMainnet: return "https://scan.tomochain.com/api/"
            case .TomoChainTestnet: return "https://scan.testnet.tomochain.com/api/"
            }
        }()
        return URL(string: urlString)!
    }
}

extension RPCServer: Equatable {
    static func == (lhs: RPCServer, rhs: RPCServer) -> Bool {
        switch (lhs, rhs) {
        case (let lhs, let rhs):
            return lhs.chainID == rhs.chainID
        }
    }
}

