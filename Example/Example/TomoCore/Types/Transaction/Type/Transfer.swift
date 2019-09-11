//
//  Transfer.swift
//  Example
//
//  Created by Admin on 9/5/19.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import BigInt


struct Transfer {
    let server: RPCServer
    let type: TransferType
}

enum TransferType {
    case tomo
    case token(TRCToken, tokenBalance: BigInt)
}


