//
//  ChainStateProvider.swift
//  Example
//
//  Created by Admin on 9/10/19.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation


import Foundation
import BigInt
import Result
import PromiseKit
import Moya


final class ChainSate {
    
    struct Keys {
        static let latestBlock = "chainID"
        static let gasPrice = "gasPrice"
    }
    
    private var latestBlockKey: String {
        return "\(server.chainID)-" + Keys.latestBlock
    }
    
    private var gasPriceBlockKey: String {
        return "\(server.chainID)-" + Keys.gasPrice
    }
    
    
    var latestBlock: Int {
        get {
            return defaults.integer(forKey: latestBlockKey)
        }
        set {
            defaults.set(newValue, forKey: latestBlockKey)
        }
    }
    var gasPrice: BigInt? {
        get {
            guard let value = defaults.string(forKey: gasPriceBlockKey) else { return .none }
            return BigInt(value, radix: 10)
        }
        set { defaults.set(newValue?.description, forKey: gasPriceBlockKey) }
    }
    
    let defaults: UserDefaults
  
    
    let server: RPCServer
    let provider:MoyaProvider<Api>
    init(
        server: RPCServer,
        provider:MoyaProvider<Api>
        ) {
        self.server = server
        self.provider = provider
        self.defaults = UserDefaults.standard
    }
    
    func fetch(){
        self.getGasPrice()
        self.getLastBlock()
    }
    
    private func getLastBlock() {
        provider.request(.lastBlock(server: self.server)) { (result) in
            switch result {
            case .success(let response):
                guard let responseValue:[String: Any] = (try! response.mapJSON() as? [String: Any]),let blockNumerHash = responseValue["result"] as? String, let value = BigInt(blockNumerHash.drop0x, radix: 16) else{
                    return
                }
                self.latestBlock =  numericCast(value)
            case .failure(let error):
                print(error)
            }
        }
        
    }
    
    private func getGasPrice() {
        provider.request(.getGasPrice(server: self.server)) { (result) in
            switch result{
            case .success(let response):
                guard let responseValue:[String: Any] = (try! response.mapJSON() as? [String: Any]),let blockNumerHash = responseValue["result"] as? String, let value = BigInt(blockNumerHash.drop0x, radix: 16) else{
                    return
                }
                self.gasPrice = value
            case .failure(let error):
                print(error)
            }
        }
    
    }
}


