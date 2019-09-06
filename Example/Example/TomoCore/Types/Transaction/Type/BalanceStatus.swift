//
//  BalanceStatus.swift
//  Example
//
//  Created by Admin on 9/5/19.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
// Copyright DApps Platform Inc. All rights reserved.

import Foundation

enum BalanceStatus {
    case tomo(tomoSufficient: Bool, gasSufficient: Bool)
    case token(tokenSufficient: Bool, gasSufficient: Bool)
}

extension BalanceStatus {
    enum Key {
        case insufficientTomo
        case insufficientGas
        case insufficientToken
        case correct
        
        var string: String {
            switch self {
            case .insufficientTomo:
                return NSLocalizedString("send.error.insufficientTomo", value: "Insufficient %@ balance", comment: "")
            case .insufficientGas:
                return NSLocalizedString("send.error.insufficientGas", value: "Insufficient %@ to cover gas fee", comment: "")
            case .insufficientToken:
                return NSLocalizedString("send.error.insufficientToken", value: "Insufficient %@ token balance", comment: "")
            case .correct:
                return ""
            }
        }
    }
    
    var sufficient: Bool {
        switch self {
        case .tomo(let etherSufficient, let gasSufficient):
            return etherSufficient && gasSufficient
        case .token(let tokenSufficient, let gasSufficient):
            return tokenSufficient && gasSufficient
        }
    }
    
    var insufficientTextKey: Key {
        switch self {
        case .tomo(let etherSufficient, let gasSufficient):
            if !etherSufficient {
                return .insufficientTomo
            }
            if !gasSufficient {
                return .insufficientGas
            }
        case .token(let tokenSufficient, let gasSufficient):
            if !tokenSufficient {
                return .insufficientToken
            }
            if !gasSufficient {
                return .insufficientGas
            }
        }
        return .correct
    }
    
    var insufficientText: String {
        return insufficientTextKey.string
    }
}

