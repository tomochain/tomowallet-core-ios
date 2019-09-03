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
    let value: BigInt
    let account: Account
    let to: EthereumAddress?
    let nonce: BigInt
    let data: Data
    let gasPrice: BigInt
    let gasLimit: BigInt
    let chainID: Int
}
