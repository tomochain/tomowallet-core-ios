//
//  SentTransaction.swift
//  Example
//
//  Created by Admin on 9/3/19.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
public enum SentTransactionType{
    case sent
    case signed
}

public struct SentTransaction {
    public let id: String
    public let original: SignTransaction
    public let data: Data
    public let type: SentTransactionType
}
