
//
//  RPCApi.swift
//  Example
//
//  Created by Admin on 9/3/19.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import Moya
enum RPCApi{
    case getBalanceCoin(server: RPCServer, address: String)
    case lastBlock(server: RPCServer)
    case getGasPrice(server: RPCServer)
    case estimateGasLimit(server: RPCServer, transaction: SignTransaction)
    case sendRawTransaction(server: RPCServer, signedTransaction: String )
    case getTransactionCount(server: RPCServer, address: String)
    // TRC20
    case getBalanceToken(server: RPCServer, contract: String, data: String)
    case getTokenName(server: RPCServer, contract: String, data: String)
    case getTokenSymbol(server: RPCServer, contract: String, data: String)
    case getTokenDecimals(server: RPCServer, contract: String, data: String)
    case checkIsContract(server: RPCServer, contract: String)
    
    // TRC 21
    case getEstimateFeeTRC21(server: RPCServer, contract: String, data: String)
    
    // transactions
    case getTransactionByHash(server: RPCServer, txHash: String)
    case getTransactionReceipt(server: RPCServer, txHash: String)
    
    //
    case getEstimateGasPrice(baseURL: URL)
    
}
extension RPCApi: TargetType{
    var baseURL: URL{
        switch self {
        case .getBalanceCoin(let server, _):
            return  server.rpcURL
        case .getBalanceToken(let server, _, _):
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
        case .getTokenName(let server, _, _):
            return server.rpcURL
        case .getTokenSymbol(let server, _, _):
            return server.rpcURL
        case .getTokenDecimals(let server, _, _):
            return server.rpcURL
        case .getTransactionByHash(let server,_):
            return server.rpcURL
        case .getTransactionReceipt(let server,_):
            return server.rpcURL
        case .getEstimateFeeTRC21(let server, _, _):
            return server.rpcURL
            
        case .getEstimateGasPrice(let baseURL):
            return baseURL
            
            
        case .checkIsContract(let server, _):
            return server.rpcURL
        }
        
    }
    
    var path: String {
        switch self {
        case .getEstimateGasPrice:
            return "/settings/estimate-gasprice"
        default:
            return ""
        }
        
    }
    
    var method: Moya.Method {
        switch self {
        case .getBalanceCoin: return .post
        case .getBalanceToken, .getTokenName, .getTokenSymbol, .getTokenDecimals: return .post
        case .lastBlock: return .post
        case .getGasPrice: return.post
        case .estimateGasLimit: return .post
        case .sendRawTransaction: return .post
        case .getTransactionCount: return .post
        case .getTransactionByHash: return .post
        case .getTransactionReceipt: return .post
        case .getEstimateGasPrice: return .get
        case .checkIsContract: return .post
        case .getEstimateFeeTRC21: return .post
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
        case .getBalanceToken(_, let contract, let data):
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
                        "from": "\(transaction.account.address.description.lowercased())",
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
        case .getTokenName(_, let contract, let data):
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
        case .getTokenSymbol(_, let contract, let data):
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
        case .getTokenDecimals(_, let contract, let data):
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
        case .getEstimateGasPrice:
            return .requestPlain
        case .checkIsContract(_, let contract):
            let parameters = [
                "jsonrpc": "2.0",
                "method": "eth_getCode",
                "params": ["\(contract)","latest"],
                "id": 1
                ] as [String : Any]
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
            
        case .getEstimateFeeTRC21(_, let contract,let data):
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

