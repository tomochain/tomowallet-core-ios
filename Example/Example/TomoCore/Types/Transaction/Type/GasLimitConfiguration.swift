// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import BigInt

public struct GasLimitConfiguration {
    static let `default` = BigInt(50_000)
    static let tokenTransfer = BigInt(500_000)
}
