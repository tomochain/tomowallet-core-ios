//
//  BigIntExtention.swift
//  Example
//
//  Created by Admin on 9/3/19.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation

import Foundation
import BigInt
extension BigInt{
    var hexEncoded: String {
        return "0x" + String(self, radix: 16)
    }
}
