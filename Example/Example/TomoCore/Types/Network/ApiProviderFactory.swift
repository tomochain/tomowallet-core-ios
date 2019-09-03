//
//  ApiProviderFactory.swift
//  Example
//
//  Created by Admin on 9/3/19.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import Moya
import Alamofire
struct ApiProviderFactory {
    static let policies: [String: ServerTrustPolicy] = [
        :
    ]
    static func makeRPCNetworkProvider() -> MoyaProvider<RPCApi> {
        let manager = Manager(
            configuration: URLSessionConfiguration.default,
            serverTrustPolicyManager: ServerTrustPolicyManager(policies: policies)
        )
        return MoyaProvider<RPCApi>(manager: manager)
    }
}
