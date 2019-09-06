// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import BigInt

public struct GasPriceConfiguration {
    static let `default`: BigInt = TomoNumberFormatter.full.number(from: "24", units: .wei)!
    static let min: BigInt = TomoNumberFormatter.full.number(from: "1", units: .wei)!
    static let max: BigInt = TomoNumberFormatter.full.number(from: "300000000", units: .wei)!
}
