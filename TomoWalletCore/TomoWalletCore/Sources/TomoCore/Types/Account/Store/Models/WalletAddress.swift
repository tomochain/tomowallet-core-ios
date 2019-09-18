//
//  WalletAddress.swift
//  Example
//
//  Created by Admin on 8/31/19.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
struct WalletAddress: Codable {
    let id: String = UUID().uuidString;
    let addressString: String
    let rawCoin: Int
    public var coin: Coin {
        get { return Coin(rawValue: rawCoin) ?? .tomo }
       
    }
    
    init(
        coin: Coin,
        address: Address
        ) {
        self.addressString = address.description
        self.rawCoin = coin.rawValue
    }
    
    var address: EthereumAddress? {
        return EthereumAddress(string: addressString)
    }
}



