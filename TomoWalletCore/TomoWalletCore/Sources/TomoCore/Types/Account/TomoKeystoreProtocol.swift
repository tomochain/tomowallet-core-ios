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
    
    var keysDirectory: URL { get }
    func createWallet(completion: @escaping(Result<TomoWallet, TomoKeystoreError>) -> Void)
    func getwallets() -> [TomoWallet]
    func getWallet(address: String, completion: @escaping(Result<TomoWallet, TomoKeystoreError>) -> Void)
    func importWallet(hexPrivateKey: String, completion: @escaping(Result<TomoWallet, TomoKeystoreError>) -> Void)
    func importWallet(words: String , completion: @escaping(Result<TomoWallet, TomoKeystoreError>) -> Void)
    func importAddressOnly(address: String, completion: @escaping(Result<TomoWallet, TomoKeystoreError>) -> Void)
    
}

