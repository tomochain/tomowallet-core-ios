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
    let walletObjectPath = Bundle.main.path(forResource: "TomoWalletObjects", ofType: "json")
    let walletAddressPath = Bundle.main.path(forResource: "WalletAddress", ofType: "json")
    
 

    init() {
        
    
    }
    func storeWalletObject(wallet: TomoWalletObject) {
     
    }

    func get(for type: TomoWalletType) -> TomoWalletObject {
        return TomoWalletObject()

    }
    
    func store(address: WalletAddress) {
        if let path = Bundle.main.path(forResource: walletAddressPath, ofType: "json"){
            do {
                let data = try PropertyListEncoder().encode(address)
                NSKeyedArchiver.archiveRootObject(data, toFile: path)
                print("saved")
            } catch {
                print("Save Failed")
            }
        }
    }
    func delete(address: WalletAddress) {

    }
    
    var addresses: [WalletAddress]{
        var walletsArddress = [WalletAddress]()
        if let path = Bundle.main.path(forResource: walletAddressPath, ofType: "json") {
            do {
                guard let data = NSKeyedUnarchiver.unarchiveObject(withFile: path) as? Data else { return walletsArddress }
                    walletsArddress = try PropertyListDecoder().decode([WalletAddress].self, from: data)
                
            } catch {
                print("error")
            }
        }
        return walletsArddress
    }
    
}

