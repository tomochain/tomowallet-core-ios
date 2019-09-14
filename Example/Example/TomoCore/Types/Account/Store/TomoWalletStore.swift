//
//  TomoWalletStore.swift
//  Example
//
//  Created by Admin on 8/31/19.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
class TomoWalletStorage {
    let encoder = PropertyListEncoder()
    let fileManager = FileManager.default
    let walletObjectPath = Bundle.main.path(forResource: "WalletObjects", ofType: "json")
    let walletAddressPath = Bundle.main.path(forResource: "WalletAddress", ofType: "json")

    init() {
    
    }
    func storeWalletObject(wallet: TomoWalletObject) {
     
    }

    func get(for type: TomoWalletType) -> TomoWalletObject {
        return TomoWalletObject()

    }
    
    func store(address: [WalletAddress]) {

    }
    func delete(address: WalletAddress) {

    }
    
}

