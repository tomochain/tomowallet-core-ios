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
import PromiseKit

enum NetworkProviderError: LocalizedError{
    case invalidAddress
    case notCreateResponeValue
    
    var errorDescription: String{
        return ""
    }
}

protocol NetworkProviderProtocol {
    func tomoBalance() -> Promise<BigInt>
    // TRC
    func tokenBalance(tokenAddress: String) -> Promise<BigInt>
    func tokenDecimals(tokenAddress: String) -> Promise<BigInt>
    func tokenName(tokenAddress: String) -> Promise<String>
    func tokenSymbol(tokenAddress: String) -> Promise<String>
    func tokenTotalSupply(tokenAddress: String) -> Promise<BigInt>

    
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
    
    func balance() -> Promise<BigInt> {
        return Promise {seal in
            provider.request(.getBalanceCoin(server: self.server, address: address.description), completion: { (result) in
                switch result {
                case .success(let response):
                    do {
                        let balanceDecodable = try response.map(RPCResultsDecodable.self)
                        guard let value = BigInt(balanceDecodable.result.drop0x, radix: 16) else{
                            return seal.reject(NetworkProviderError.notCreateResponeValue)
                        }
                        seal.fulfill(value)
                    } catch {
                        seal.reject(error)
                    }
                case .failure(let error):
                    seal.reject(error)
                }
            })
            
        }
       
    }
    
    func TRCBalance(tokenAddress: String) -> Promise<BigInt> {
        return Promise{ seal in
            guard let contract = EthereumAddress(string: tokenAddress),let ownerAddress = EthereumAddress(string: address.description)  else {
                return seal.reject(NetworkProviderError.invalidAddress)
            }
            
            let balanceEncoder = ERC20Encoder.encodeBalanceOf(address: ownerAddress)
            provider.request(.getBalanceToken(server: self.server, contract: contract.description, data: balanceEncoder.hexEncoded)) { (result) in
                switch result {
                case .success(let response):
                    do {
                        let balanceDecodable = try response.map(RPCResultsDecodable.self)
                        guard let value = BigInt(balanceDecodable.result.drop0x, radix: 16) else{
                             return seal.reject(NetworkProviderError.notCreateResponeValue)
                        }
                        seal.fulfill(value)
                    } catch {
                        seal.reject(error)
                    }
                case .failure(let error):
                    seal.reject(error)
                }
            }
        }
    
    }
    
    
}
extension NetworkProvider: NetworkProviderProtocol{
    func tokenDecimals(tokenAddress: String) -> Promise<BigInt> {
        return Promise{ seal in
            guard let contract = EthereumAddress(string: tokenAddress) else {
                return seal.reject(NetworkProviderError.invalidAddress)
            }
            
            let balanceEncoder = ERC20Encoder.encodeDecimals()
            provider.request(.getTokenDecimals(server: self.server, contract: contract.description, data: balanceEncoder.hexEncoded), completion: { (result) in
                switch result {
                case .success(let response):
                    do {
                        let decimalsDecodable = try response.map(RPCResultsDecodable.self)
                        guard let value = BigInt(decimalsDecodable.result.drop0x, radix: 16) else{
                             return seal.reject(NetworkProviderError.notCreateResponeValue)
                        }
                        seal.fulfill(value)
                    } catch {
                        seal.reject(error)
                    }
                case .failure(let error):
                    seal.reject(error)
                }
            })
        }
    }
    
    func tokenTotalSupply(tokenAddress: String) -> Promise<BigInt> {
        return Promise{ seal in
            guard let contract = EthereumAddress(string: tokenAddress) else {
                return seal.reject(NetworkProviderError.invalidAddress)
            }
            
            let balanceEncoder = ERC20Encoder.encodeDecimals()
            provider.request(.getTokenDecimals(server: self.server, contract: contract.description, data: balanceEncoder.hexEncoded), completion: { (result) in
                switch result {
                case .success(let response):
                    do {
                        let balanceDecodable = try response.map(RPCResultsDecodable.self)
                        guard let value = BigInt(balanceDecodable.result.drop0x, radix: 16) else{
                             return seal.reject(NetworkProviderError.notCreateResponeValue)
                        }
                        seal.fulfill(value)
                    } catch {
                        seal.reject(error)
                    }
                case .failure(let error):
                    seal.reject(error)
                }
            })
        }
        
    }

    
    func tokenName(tokenAddress: String) -> Promise<String> {
        return Promise{ seal in
            guard let contract = EthereumAddress(string: tokenAddress) else {
                return seal.reject(NetworkProviderError.invalidAddress)
            }
            
            let balanceEncoder = ERC20Encoder.encodeDecimals()
            provider.request(.getTokenDecimals(server: self.server, contract: contract.description, data: balanceEncoder.hexEncoded), completion: { (result) in
                switch result {
                case .success(let response):
                    do {
                        let balanceDecodable = try response.map(RPCResultsDecodable.self)
                        guard let value = BigInt(balanceDecodable.result.drop0x, radix: 16) else{
                             return seal.reject(NetworkProviderError.notCreateResponeValue)
                        }
                        seal.fulfill("value")
                    } catch {
                        seal.reject(error)
                    }
                case .failure(let error):
                    seal.reject(error)
                }
            })
        }
    
    }
    
    func tokenSymbol(tokenAddress: String) -> Promise<String> {
        return Promise{ seal in
            guard let contract = EthereumAddress(string: tokenAddress) else {
                return seal.reject(NetworkProviderError.invalidAddress)
            }
            
            let balanceEncoder = ERC20Encoder.encodeDecimals()
            provider.request(.getTokenDecimals(server: self.server, contract: contract.description, data: balanceEncoder.hexEncoded), completion: { (result) in
                switch result {
                case .success(let response):
                    do {
                        let balanceDecodable = try response.map(RPCResultsDecodable.self)
                        guard let value = BigInt(balanceDecodable.result.drop0x, radix: 16) else{
                             return seal.reject(NetworkProviderError.notCreateResponeValue)
                        }
                        seal.fulfill("")
                    } catch {
                        seal.reject(error)
                    }
                case .failure(let error):
                    seal.reject(error)
                }
            })
        }
    }
    
    func tokenTotalSupply(tokenAddress: String) -> Promise<Int> {
        return Promise{ seal in
            guard let contract = EthereumAddress(string: tokenAddress) else {
                return seal.reject(NetworkProviderError.invalidAddress)
            }
            
            let balanceEncoder = ERC20Encoder.encodeDecimals()
            provider.request(.getTokenDecimals(server: self.server, contract: contract.description, data: balanceEncoder.hexEncoded), completion: { (result) in
                switch result {
                case .success(let response):
                    do {
                        let balanceDecodable = try response.map(RPCResultsDecodable.self)
                        guard let value = BigInt(balanceDecodable.result.drop0x, radix: 16) else{
                            return seal.reject(NetworkProviderError.notCreateResponeValue)
                        }
                        seal.fulfill(2)
                    } catch {
                        seal.reject(error)
                    }
                case .failure(let error):
                    seal.reject(error)
                }
            })
        }
    }
    
    func tomoBalance() -> Promise<BigInt> {
        return self.balance()
    }
    
    func tokenBalance(tokenAddress: String) -> Promise<BigInt> {
        return self.TRCBalance(tokenAddress: tokenAddress)
    }
    
}
