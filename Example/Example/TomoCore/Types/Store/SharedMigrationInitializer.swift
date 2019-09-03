//
//  SharedMigrationInitializer.swift
//  TomoWallet
//
//  Created by TomoChain on 8/14/18.
//  Copyright © 2018 TomoChain. All rights reserved.
//

import Foundation
import RealmSwift

import Foundation
protocol Initializer {
    func perform()
}

final class SharedMigrationInitializer: Initializer{
    lazy var config: Realm.Configuration = {
        return RealmConfiguration.sharedConfiguration()
    }()
    
    init() { }
    
    func perform() {
        self.config.schemaVersion = 1
        config.migrationBlock = { migration, oldSchemaVersion in
            switch oldSchemaVersion {
            default:
                break
            }
            // do somethings here
        }
    }
}
