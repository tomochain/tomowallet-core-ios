//
//  Uniti.swift
//  Example
//
//  Created by Admin on 9/4/19.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation

import Foundation
public enum EthereumUnit: Int64 {
    case wei = 1
    case kwei = 1_000
    case gwei = 1_000_000_000
    case tomo = 1_000_000_000_000_000_000
}

extension EthereumUnit {
    var name: String {
        switch self {
        case .wei: return "Wei"
        case .kwei: return "Kwei"
        case .gwei: return "Gwei"
        case .tomo: return "Tomo"
        }
    }
}


