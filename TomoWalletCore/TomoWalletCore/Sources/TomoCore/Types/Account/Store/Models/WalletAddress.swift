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
    
//    enum CodingKeys: String, CodingKey {
//        case title
//        case price
//        case quantity
//    }
//    
//    init(title:String,price:Double, quantity:Int) {
//        self.title = title
//        self.price = price
//        self.quantity = quantity
//    }
//    
//    func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(title, forKey: .title)
//        try container.encode(price, forKey: .price)
//        try container.encode(quantity, forKey: .quantity)
//    }
//    
//    init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        title = try container.decode(String.self, forKey: .title)
//        price = try container.decode(Double.self, forKey: .price)
//        quantity = try container.decode(Int.self, forKey: .quantity)
//    }
    
}


