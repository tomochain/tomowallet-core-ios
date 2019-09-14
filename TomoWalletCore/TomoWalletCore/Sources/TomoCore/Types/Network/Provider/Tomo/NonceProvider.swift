//
//  NonceProvider.swift
//  Example
//
//  Created by Admin on 9/5/19.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation

// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import BigInt
import Result
import PromiseKit
import Moya
protocol NonceProvider {
     func getNextNonce() -> Promise<BigInt>
}

final class GetNonceProvider: NonceProvider {
    func getNextNonce() -> Promise<BigInt> {
        return Promise{ seal in
            provider.request(.getTransactionCount(server: self.server, address: address.description)) { (result) in
                switch result{
                case.success(let response):
                    guard let responseValue:[String: Any] = (try! response.mapJSON() as? [String: Any]),let countHash = responseValue["result"] as? String, let count = BigInt(countHash.drop0x, radix: 16) else{
                        return seal.reject(NetworkProviderError.notCreateResponeValue)
                        
                    }
                    seal.fulfill(count)
                case .failure(let error):
                    seal.reject(error)
                }
            }
        }
    }
    
    let server: RPCServer
    let address: Address
    let provider:MoyaProvider<Api>
    init(
        server: RPCServer,
        address: Address,
        provider:MoyaProvider<Api>
        ) {
        self.server = server
        self.address = address
        self.provider = provider
    }
}

