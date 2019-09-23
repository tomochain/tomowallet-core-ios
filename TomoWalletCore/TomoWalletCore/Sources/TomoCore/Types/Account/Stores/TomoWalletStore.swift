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
    var walletAddressURL: URL?
    var walletObjectsURL: URL?
    
    
    init() {
        
        let walletAddressFileName = "Database"
        let fileManager = FileManager.default
        let documentsFolder = try! fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        let folderURL = documentsFolder.appendingPathComponent(walletAddressFileName)
        let folderExists = (try? folderURL.checkResourceIsReachable()) ?? false
        do {
            if !folderExists {
                try fileManager.createDirectory(at: folderURL, withIntermediateDirectories: false)
            }
            walletAddressURL = folderURL.appendingPathComponent("WalletAddress.json")
            walletObjectsURL = folderURL.appendingPathComponent("walletObjects.json")
        } catch { print(error) }
    }

//    func get(for type: TomoWalletType) -> TomoWalletObject {
//        
////        let firstWallet = realm.objects(WalletObject.self).filter { $0.id == type.description }.first
////        guard let foundWallet = firstWallet else {
////            return WalletObject.from(type)
////        }
////        return foundWallet
//        return TomoWalletObject()
//
//    }
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func store(address: WalletAddress) {
        var currentAddresses = addresses
        currentAddresses.append(address)
        do {
            let JsonData = try JSONEncoder().encode(currentAddresses)
            try JsonData.write(to: walletAddressURL!)
        } catch {
            print(error.localizedDescription)
        }
    }
    func delete(address: WalletAddress) {
        let newAddresses = addresses.filter{$0.addressString.lowercased() != address.addressString.lowercased()}
        do {
            let JsonData = try JSONEncoder().encode(newAddresses)
            try JsonData.write(to: walletAddressURL!)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    var addresses: [WalletAddress] {
        var walletsArddress = [WalletAddress]()
            do {
                let data = try Data(contentsOf: walletAddressURL!)
                walletsArddress = try JSONDecoder().decode([WalletAddress].self, from: data)
            } catch {
                print(error.localizedDescription)
            }
        return walletsArddress
    }
    
    
    func storeWalletInfo(walletObject: TomoWalletObject) {
        var currentWalletObjects = walletObjects
        currentWalletObjects.append(walletObject)
        do {
            let JsonData = try JSONEncoder().encode(currentWalletObjects)
            try JsonData.write(to: walletObjectsURL!)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    var walletObjects: [TomoWalletObject] {
        var walletObjects = [TomoWalletObject]()
        do {
            let data = try Data(contentsOf: walletObjectsURL!)
            walletObjects = try JSONDecoder().decode([TomoWalletObject].self, from: data)
        } catch {
            print(error.localizedDescription)
        }
        return walletObjects
    }
    
}

