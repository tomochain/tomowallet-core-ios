//
//  Tomokeystore.swift
//  Example
//
//  Created by Admin on 8/29/19.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import UIKit
class TomoKeystore: TomoAPI {
    var hasWallets: Bool{
        return true
    }
    
    public static let keychainKeyPrefix = "tomowallet"
    let keyStore: KeyStore
    let derivationPath : DerivationPath
    init() {
        let documentPath_url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        derivationPath = DerivationPath(purpose: 44, coinType: Coin.tomo.rawValue)
        keyStore = try! KeyStore(keyDirectory: documentPath_url)
    }

    func createWallet( completion:@escaping ()->())  {
        DispatchQueue.global(qos: .userInitiated).async {
            let password = PasswordGenerator.generateRandom()
            let wallet = try? self.keyStore.createWallet(password: password, derivationPaths: [self.derivationPath])
            DispatchQueue.main.async {
                completion()
            }
        }
    }
    func importWalletPrivatekey(privatekey: String, completion: @escaping()->()) {
        
    }
}


