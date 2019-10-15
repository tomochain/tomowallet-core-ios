//
//  SignTransaction.swift
//  Example
//
//  Created by Admin on 9/3/19.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import BigInt

public struct SignTransaction {
    public let tranfer: Transfer
    public let value: BigInt
    public let from: EthereumAddress
    public let to: EthereumAddress?
    public let nonce: BigInt
    public let data: Data
    public let gasPrice: BigInt
    public let gasLimit: BigInt
    public let gasFeeByTRC21: BigInt?
    public let chainID: Int
}
