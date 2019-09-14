//
//  WalletAddress.swift
//  Example
//
//  Created by Admin on 8/31/19.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
final class WalletAddress: Decodable {
    @objc dynamic var id: String = UUID().uuidString;
    @objc dynamic var addressString: String = "";
    @objc private dynamic var rawCoin = -1
    public var coin: Coin {
        get { return Coin(rawValue: rawCoin) ?? .ethereum }
        set { rawCoin = newValue.rawValue }
    }
    
    convenience init(
        coin: Coin,
        address: Address
        ) {
        self.init()
        self.addressString = address.description
        self.coin = coin
    }
    
    var address: EthereumAddress? {
        return EthereumAddress(string: addressString)
    }
    
}


