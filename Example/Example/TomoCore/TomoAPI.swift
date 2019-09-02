//
//  TomoAPI.swift
//  Example
//
//  Created by Admin on 8/29/19.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation

protocol TomoAPI: class {
    var hasWallets: Bool { get };
    func createWaWallet()
    func getCurrentWallet()
    func getBabance()
    func getTRC21(tokenAddress:String,completion:@escaping()->())
}
