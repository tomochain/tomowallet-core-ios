//
//  RealmConfiguration.swift
//  TomoWallet
//
//  Created by TomoChain on 8/14/18.
//  Copyright © 2018 TomoChain. All rights reserved.
//

import Foundation
import RealmSwift
struct RealmConfiguration {
    
    static func sharedConfiguration() -> Realm.Configuration {
        var config = Realm.Configuration()
        let directory = config.fileURL!.deletingLastPathComponent()
        let url = directory.appendingPathComponent("shared.realm")
        config.fileURL = url
        return config
    }
    
    static func configuration(for account: WalletInfo) -> Realm.Configuration {
        var config = Realm.Configuration()
        let directory = config.fileURL!.deletingLastPathComponent()
        let newURL = directory.appendingPathComponent("\(account.description).realm")

        return Realm.Configuration(fileURL: newURL)
    }
}
