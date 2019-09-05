//
//  TRC21Encoder.swift
//  Example
//
//  Created by Admin on 9/4/19.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import BigInt
public class TRC21Encoder: ERC20Encoder{
    /// Encodes a function call to `totalSupply`
    ///
    /// Solidity function: `function totalSupply() public constant returns (uint);`
    public static func estimateFee(amount: BigUInt) -> Data {
        let function = Function(name: "estimateFee", parameters: [.uint(bits: 256)])
        let encoder = ABIEncoder()
        try! encoder.encode(function: function, arguments: [amount])
        return encoder.data
    }
    
}
