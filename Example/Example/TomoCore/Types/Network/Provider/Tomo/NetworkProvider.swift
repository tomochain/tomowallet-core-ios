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
    func tokenBalance(contract: String) -> Promise<BigInt>
    func tokenDecimals(contract: String) -> Promise<BigInt>
    func tokenName(contract: String) -> Promise<String>
    func tokenSymbol(contract: String) -> Promise<String>
    func tokenTotalSupply(contract: String) -> Promise<BigInt>
    func isContract(contract: String) -> Promise<Bool>
    
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
            provider.request(.getTokenInfo(server: self.server, contract: contract.description, data: balanceEncoder.hexEncoded)) { (result) in
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
    func isContract(contract: String) -> Promise<Bool> {
        return Promise { seal in
            provider.request(.checkIsContract(server: server, contract: address.description), completion: { (result) in
                switch result {
                case .success(let response):
                    do {
                        let responesDecodable = try response.map(RPCResultsDecodable.self)
                        if responesDecodable.result == "0x"{
                            seal.fulfill(false)
                        }else{
                            seal.fulfill(true)
                        }
                    } catch {
                        seal.reject(error)
                    }
                case .failure(let error):
                    seal.reject(error)
                }
            })
            
        }
    }
    
    func tokenDecimals(contract: String) -> Promise<BigInt> {
        return Promise{ seal in
            guard let contract = EthereumAddress(string: contract) else {
                return seal.reject(NetworkProviderError.invalidAddress)
            }
            let balanceEncoder = ERC20Encoder.encodeDecimals()
            provider.request(.getTokenInfo(server: self.server, contract: contract.description, data: balanceEncoder.hexEncoded), completion: { (result) in
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
    
    func tokenTotalSupply(contract: String) -> Promise<BigInt> {
        return Promise{ seal in
            guard let contract = EthereumAddress(string: contract) else {
                return seal.reject(NetworkProviderError.invalidAddress)
            }
            
            let totalSypplyEncoder = ERC20Encoder.encodeTotalSupply()
            provider.request(.getTokenInfo(server: self.server, contract: contract.description, data: totalSypplyEncoder.hexEncoded), completion: { (result) in
                switch result {
                case .success(let response):
                    do {
                        let totalSupplyDecodable = try response.map(RPCResultsDecodable.self)
                        guard let value = BigInt(totalSupplyDecodable.result.drop0x, radix: 16) else{
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

    
    func tokenName(contract: String) -> Promise<String> {
        return Promise{ seal in
            guard let contract = EthereumAddress(string: contract) else {
                return seal.reject(NetworkProviderError.invalidAddress)
            }
            
            let nameEncoder = ERC20Encoder.encodeName()
            provider.request(.getTokenInfo(server: self.server, contract: contract.description, data: nameEncoder.hexEncoded), completion: { (result) in
                switch result {
                case .success(let response):
                    do {
                        let nameDecodable = try response.map(RPCResultsDecodable.self)
                        let data = Data(hexString: nameDecodable.result)
                        guard let name = String.init(data: data!, encoding: .utf8) else{
                            return seal.reject(NetworkProviderError.notCreateResponeValue)
                        }
                        seal.fulfill(name)
                    } catch {
                        seal.reject(error)
                    }
                case .failure(let error):
                    seal.reject(error)
                }
            })
        }
    
    }
    
    func tokenSymbol(contract: String) -> Promise<String> {
        return Promise{ seal in
            guard let contract = EthereumAddress(string: contract) else {
                return seal.reject(NetworkProviderError.invalidAddress)
            }
            let symbolEncoder = ERC20Encoder.encodeSymbol()
            provider.request(.getTokenInfo(server: self.server, contract: contract.description, data: symbolEncoder.hexEncoded), completion:{ (result) in
                switch result {
                case .success(let response):
                    do {
                        let symbolDecodable = try response.map(RPCResultsDecodable.self)
                        let data = Data(hexString: symbolDecodable.result)
                        guard let symbol = String.init(data: data!, encoding: .utf8) else{
                            return seal.reject(NetworkProviderError.notCreateResponeValue)
                        }
                        
                        seal.fulfill(symbol)
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
    
    func tokenBalance(contract: String) -> Promise<BigInt> {
        return self.TRCBalance(tokenAddress: contract)
    }
    
}
