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

protocol NetworkProviderProtocol {
    func tomoBalance(completion: @escaping(Result<BigInt,Error>) -> Void)
    func tokenBalance(tokenAddress: String, completion: @escaping(Result<BigInt,Error>) -> Void)
}
final class NetworkProvider {
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
    
    func TRCBalance(tokenAddress: String, completion: @escaping (Result<BigInt, Error>) -> Void){
        guard let contract = EthereumAddress(string: tokenAddress),let ownerAddress = EthereumAddress(string: address.description)  else {
            completion(.failure(TomoKeystoreError.invalidAddress))
            return
        }
        
        let balanceEncoder = ERC20Encoder.encodeBalanceOf(address: ownerAddress)
        provider.request(.getBalanceToken(server: self.server, contract: contract.description, data: balanceEncoder.hexEncoded)) { (result) in
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
        }
    }
    
    
}
extension NetworkProvider: NetworkProviderProtocol{
    func tomoBalance(completion: @escaping (Result<BigInt, Error>) -> Void) {
        self.balance(completion: completion)
    }
    
    func tokenBalance(tokenAddress: String, completion: @escaping (Result<BigInt, Error>) -> Void) {
        self.TRCBalance(tokenAddress: tokenAddress, completion: completion)
    }
    
    
}
