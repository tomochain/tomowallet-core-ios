//
//  SentTransaction.swift
//  Example
//
//  Created by Admin on 9/3/19.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
enum SentTransactionType{
    case sent
    case signed
}

public struct SentTransaction {
    let id: String
    let original: SignTransaction
    let data: Data
    let type: SentTransactionType
}
