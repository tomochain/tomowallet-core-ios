//
//  TomoWalletStore.swift
//  Example
//
//  Created by Admin on 8/31/19.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import RealmSwift
class TomoWalletStorage {
    let realm: Realm
    
 
    init(realm: Realm) {
        self.realm = realm
    }
    
    func get(for type: WalletType) -> TomoWalletObject {
        let firstWallet = realm.objects(TomoWalletObject.self).filter { $0.id == type.description }.first
        guard let foundWallet = firstWallet else {
            return TomoWalletObject.from(type)
        }
        return foundWallet
    }
    
    func store(address: [WalletAddress]) {
        try? realm.write {
            realm.add(address, update: true)
        }
    }
    func delete(address: WalletAddress) {
        try? realm.write {
            realm.delete(address)
        }
    }
    
}

