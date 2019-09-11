
//
//  RPCApi.swift
//  Example
//
//  Created by Admin on 9/3/19.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import Moya
enum Api{
    case getBalanceCoin(server: RPCServer, address: String)
    case lastBlock(server: RPCServer)
    case getGasPrice(server: RPCServer)
    case estimateGasLimit(server: RPCServer, transaction: SignTransaction)
    case sendRawTransaction(server: RPCServer, signedTransaction: String )
    case getTransactionCount(server: RPCServer, address: String)
    // TRC20
    case getTokenInfo(server: RPCServer, contract: String, data: String)
    case checkIsContract(server: RPCServer, contract: String)
    
    // TRC 21
    case getMinFeeTRC21(server: RPCServer, contract: String, data: String)
    case getTokenCapacityTRC21(server: RPCServer, data: String)
    
    // transactions
    case getTransactionByHash(server: RPCServer, txHash: String)
    case getTransactionReceipt(server: RPCServer, txHash: String)

    
}
extension Api: TargetType{
    var baseURL: URL{
        switch self {
        case .getBalanceCoin(let server, _):
            return  server.rpcURL
        case .getTokenInfo(let server, _, _):
            return  server.rpcURL
        case .lastBlock(let server):
            return  server.rpcURL
        case .getGasPrice(let server):
            return  server.rpcURL
        case .estimateGasLimit(let server, _):
            return server.rpcURL
        case .sendRawTransaction(let server, _):
            return server.rpcURL
        case .getTransactionCount(let server, _):
            return server.rpcURL
        case .getTransactionByHash(let server,_):
            return server.rpcURL
        case .getTransactionReceipt(let server,_):
            return server.rpcURL
        case .getMinFeeTRC21(let server, _, _):
            return server.rpcURL
        case .getTokenCapacityTRC21(let server, _):
            return server.rpcURL
        case .checkIsContract(let server, _):
            return server.rpcURL
        }
        
    }
    
    var path: String {
        return ""
    }
    
    var method: Moya.Method {
        switch self {
        case .getBalanceCoin: return .post
        case .getTokenInfo: return .post
        case .lastBlock: return .post
        case .getGasPrice: return.post
        case .estimateGasLimit: return .post
        case .sendRawTransaction: return .post
        case .getTransactionCount: return .post
        case .getTransactionByHash: return .post
        case .getTransactionReceipt: return .post
        case .checkIsContract: return .post
        case .getMinFeeTRC21: return .post
        case .getTokenCapacityTRC21: return .post
        }
        
    }
    
    var task: Task {
        switch self {
        case .getBalanceCoin(_,let address):
            let parameters = [
                "jsonrpc": "2.0",
                "method": "eth_getBalance",
                "params": ["\(address)", "latest"],
                "id": 1
                ] as [String : Any]
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
        case .lastBlock:
            let parameters = [
                "jsonrpc": "2.0",
                "method": "eth_blockNumber",
                "id": 1
                ] as [String : Any]
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
        case .getGasPrice:
            let parameters = [
                "jsonrpc": "2.0",
                "method": "eth_gasPrice",
                "id": 1
                ] as [String : Any]
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
        case .estimateGasLimit(_, let transaction):
            let parameters = [
                "jsonrpc": "2.0",
                "method": "eth_estimateGas",
                "params": [
                    [
                        "from": "\(transaction.from.description.lowercased())",
                        "to": "\(transaction.to?.description.lowercased() ?? "")",
                        "gasPrice": transaction.gasPrice.hexEncoded,
                        "value": transaction.value.hexEncoded,
                        "data": transaction.data.hexEncoded,
                    ]
                ],
                "id": 1
                ] as [String : Any]
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
        case .sendRawTransaction(_, let signedTransaction):
            let parameters = [
                "jsonrpc": "2.0",
                "method": "eth_sendRawTransaction",
                "params": ["\(signedTransaction)"],
                "id": 1
                ] as [String : Any]
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
        case .getTransactionCount(_, let address):
            let parameters = [
                "jsonrpc": "2.0",
                "method": "eth_getTransactionCount",
                "params": ["\(address)", "latest"],
                "id": 1
                ] as [String : Any]
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
        case .getTokenInfo(_, let contract, let data):
            let parameters = [
                "jsonrpc": "2.0",
                "method": "eth_call",
                "params": [
                    [
                        "to": "\(contract)",
                        "data": "\(data)"
                    ],
                    "latest"
                ],
                "id": 1
                ] as [String : Any]
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
        case .getTransactionByHash(_, let txHash):
            let parameters = [
                "jsonrpc": "2.0",
                "method": "eth_getTransactionByHash",
                "params": ["\(txHash)"],
                "id": 1
                ] as [String : Any]
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
        case .getTransactionReceipt(_, let txHash):
            let parameters = [
                "jsonrpc": "2.0",
                "method": "eth_getTransactionReceipt",
                "params": ["\(txHash)"],
                "id": 1
                ] as [String : Any]
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
        case .checkIsContract(_, let contract):
            let parameters = [
                "jsonrpc": "2.0",
                "method": "eth_getCode",
                "params": ["\(contract)","latest"],
                "id": 1
                ] as [String : Any]
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
        case .getMinFeeTRC21(let server, let contract, let data):
            let parameters = [
                "jsonrpc": "2.0",
                "method": "eth_call",
                "params": [
                    [
                        "to": "\(contract)",
                        "data": "\(data)"
                    ],
                    "latest"
                ],
                "id": 1
                ] as [String : Any]
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
        case .getTokenCapacityTRC21(let server, let data):
            let parameters = [
                "jsonrpc": "2.0",
                "method": "eth_call",
                "params": [
                    [
                        "to": "\(server.issuerContract)",
                        "data": "\(data)"
                    ],
                    "latest"
                ],
                "id": 1
                ] as [String : Any]
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
        }
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var headers: [String: String]? {
        return [
            "Content-type": "application/json"
        ]
    }
}

