//
//  UnconfirmedTransaction.swift
//  Example
//
//  Created by Admin on 9/5/19.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import BigInt
struct UnconfirmedTransaction {
    let transfer: Transfer
    let value: BigInt
    let to: EthereumAddress?
    let data: Data?
    
    let gasLimit: BigInt?
    let gasPrice: BigInt?
    let nonce: BigInt
}

