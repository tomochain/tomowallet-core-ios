//
//  BalanceNetworkProvice.swift
//  TomoWallet
//
//  Created by TomoChain on 8/20/18.
//  Copyright © 2018 TomoChain. All rights reserved.
//

import Foundation
import BigInt
import Moya
import Result

protocol BalanceNetworkProvider {
    func balance(completion: @escaping(Result<BigInt,Error>) -> Void)
}
final class CoinNetworkProvider: BalanceNetworkProvider {
 
    
    let server: RPCServer
    let address: Address
    let provider: MoyaProvider<RPCApi>
    
    init(
        server: RPCServer,
        address: Address,
        provider: MoyaProvider<RPCApi>
        ) {
        self.server = server
        self.address = address
        self.provider = provider
    }
    
    func balance(completion: @escaping (Result<BigInt, Error>) -> Void) {
        provider.request(.getBalanceCoin(server: self.server, address: address.description), completion: { (result) in
            switch result {
            case .success(let response):
                do {
                    let balanceDecodable = try response.map(RPCResultsDecodable.self)
                    guard let value = BigInt(balanceDecodable.result.drop0x, radix: 16) else{
                        // comming handel value is nil ....
                        return
                    }
                    completion(.success(value))
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        })
    }
}
