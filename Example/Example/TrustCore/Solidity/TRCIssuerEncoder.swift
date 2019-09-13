//
//  TRCIssuerEncoder.swift
//  Example
//
//  Created by Admin on 9/9/19.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation

public class TomoIssuerEncoder{
   
    public static func tokenCapacity(token: EthereumAddress) -> Data {
        let function = Function(name: "getTokenCapacity", parameters: [.address])
        let encoder = ABIEncoder()
        try! encoder.encode(function: function, arguments: [token])
        return encoder.data
    }
  
    

}

