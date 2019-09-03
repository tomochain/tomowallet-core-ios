//
//  TomoKeystoreProtocol.swift
//  Example
//
//  Created by Admin on 9/3/19.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import Result

protocol TomoKeystoreProtocol {
    func createWallet(completion: @escaping(Result<TomoWallet, TomoKeystoreError>) -> Void)
    func wallets() -> [TomoWallet]
    func getWallet(address: String, completion: @escaping(Result<TomoWallet, TomoKeystoreError>) -> Void)
}
