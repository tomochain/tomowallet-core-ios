// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import BigInt

public struct GasPriceConfiguration {
    static let `default`: BigInt = TomoNumberFormatter.full.number(from: "1000000", units: .wei)!
}
