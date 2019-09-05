//
//  TRCNetwork.swift
//  Example
//
//  Created by Admin on 9/4/19.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation


import Foundation
import Result
import Moya
import BigInt
import PromiseKit


final class ContractNetworkProvider{
    let server: RPCServer
    let provider: MoyaProvider<RPCApi>
    
    init(server: RPCServer, provider: MoyaProvider<RPCApi>){
        self.server = server
        self.provider = provider
    }
    
    func estimateTRC21(contracsAddress: EthereumAddress, amount: BigInt) -> Promise<BigInt?> {
        return Promise { seal in
            let encoded = TRC21Encoder.estimateFee(amount: amount.magnitude)
            provider.request(.getEstimateFeeTRC21(server: self.server, contract: contracsAddress.description, data: encoded.hexEncoded), completion: { (result) in
                switch result {
                case .success(let response):
                    
                    do{
                        let jsonrpcRespone = try JSONDecoder().decode(JsonrpcRespone.self, from: response.data)
                        if jsonrpcRespone.error == nil{
                            let value = BigInt(jsonrpcRespone.result?.drop0x ?? "", radix: 16)
                            seal.fulfill(value)
                        }else{
                            let error =  NSError(domain: jsonrpcRespone.error!.message, code: jsonrpcRespone.error!.code, userInfo: nil) as Error
                            
                            seal.reject(error)
                        }
                    }catch{
                        seal.reject(error)
                    }
                    
                case .failure(let error):
                    seal.reject(error)
                }
            })
        }
    }
    
    func symbolTokenERC(contracsAddress: EthereumAddress) -> Promise<String> {
        return Promise { seal in
            let encoded = ERC20Encoder.encodeSymbol()
            provider.request(.getTokenSymbol(server: self.server, contract: contracsAddress.description, data: encoded.hexEncoded), completion: { (result) in
                switch result {
                case .success(let response):
                    do {
                        let balanceDecodable = try response.map(RPCResultsDecodable.self)
                        let data = Data(hexString: balanceDecodable.result)
                        let decoder = String.init(data: data!, encoding: .utf8)
                        
                        seal.fulfill(decoder!)
                    } catch {
                        seal.reject(error)
                    }
                case .failure(let error):
                    seal.reject(error)
                }
            })
        }
    }
    
    func decimalsTokenERC(contracsAddress: EthereumAddress) -> Promise<BigInt> {
        return Promise { seal in
            let encoded = ERC20Encoder.encodeDecimals()
            provider.request(.getTokenDecimals(server: self.server, contract: contracsAddress.description, data: encoded.hexEncoded), completion: { (result) in
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
    
    func nameTokenERC(contracsAddress: EthereumAddress) -> Promise<String> {
        return Promise { seal in
            let encoded = ERC20Encoder.encodeName()
            provider.request(.getTokenName(server: self.server, contract: contracsAddress.description, data: encoded.hexEncoded), completion: { (result) in
                switch result {
                case .success(let response):
                    do {
                        let balanceDecodable = try response.map(RPCResultsDecodable.self)
                        let data = Data(hexString: balanceDecodable.result)
                        let decoder = String.init(data: data!, encoding: .utf8)
                        seal.fulfill(decoder!)
                    } catch {
                        seal.reject(error)
                    }
                case .failure(let error):
                    seal.reject(error)
                }
            })
            
        }
    }
    func isConTract(address: EthereumAddress) -> Promise<Bool> {
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
    
    
}


