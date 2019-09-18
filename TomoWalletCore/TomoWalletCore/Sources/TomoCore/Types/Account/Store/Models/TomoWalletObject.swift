//
//  TomoWalletObject.swift
//  Example
//
//  Created by Admin on 8/31/19.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation



final class TomoWalletObject: Codable{
    var id: String = ""
    var name: String = ""
    var createdAt: Date = Date()
    var completedBackup: Bool = false
    
    static func from(_ type: TomoWalletType) -> TomoWalletObject{
        let info = TomoWalletObject()
        info.id = type.description
        return info
    }
    
}

