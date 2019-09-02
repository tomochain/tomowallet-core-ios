//
//  SharedMigrationInitializer.swift
//  TomoWallet
//
//  Created by TomoChain on 8/14/18.
//  Copyright © 2018 TomoChain. All rights reserved.
//

import Foundation
import RealmSwift
final class SharedMigrationInitializer: Initializer{
    lazy var config: Realm.Configuration = {
        return RealmConfiguration.sharedConfiguration()
    }()
    
    init() { }
    
    func perform() {
        self.config.schemaVersion = Config.dbMigrationSchemaVersion
        config.migrationBlock = { migration, oldSchemaVersion in
            switch oldSchemaVersion {
            case 0...11:
                migration.deleteData(forType: TokenObject.className())
                migration.deleteData(forType: Transaction.className())
                migration.deleteData(forType: LocalizeTransactionDataObject.className())
            case 12...26:
                migration.deleteData(forType: NewTransaction.className())
                migration.enumerateObjects(ofType: TokenObject.className()) { oldObject, newObject in
                // combine name fields into a single field
                    newObject!["verified"] = false
                }
            default:
                break
            }
            // do somethings here
        }
    }
}
