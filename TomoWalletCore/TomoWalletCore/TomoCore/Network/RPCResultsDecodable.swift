//
//  RPCResultsDecodable.swift
//  Example
//
//  Created by Admin on 9/3/19.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
struct RPCResultsDecodable: Decodable {
    let result: String
    let jsonrpc: String
    let id :Int64
    
    private enum keys: String, CodingKey {
        case result
        case jsonrpc
        case id
        
    }
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: keys.self)
        self.result = try values.decode(String.self, forKey: .result)
        self.jsonrpc = try values.decode(String.self, forKey: .jsonrpc)
        self.id = try values.decode(Int64.self, forKey: .id)
    }
    
}

