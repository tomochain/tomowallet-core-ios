//
//  TomoWalletObject.swift
//  Example
//
//  Created by Admin on 8/31/19.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import RealmSwift
final class TomoWalletObject: Object{
    @objc dynamic var id: String = ""
    @objc dynamic var name: String = ""
    @objc dynamic var createdAt: Date = Date()
    @objc dynamic var completedBackup: Bool = false
    @objc dynamic var mainWallet: Bool = false
    @objc dynamic var balance: String = ""
    override static func primaryKey() -> String? {
        return "id"
    }
    static func from(_ type: TomoWalletType) -> TomoWalletObject{
        let info = TomoWalletObject()
        info.id = type.description
        return info
    }
    
}

