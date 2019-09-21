//
//  SkipBackupFilesInitializer.swift
//  TomoWalletCore
//
//  Created by Admin on 9/19/19.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation

public protocol Initializer {
    func perform()
}

struct SkipBackupFilesInitializer: Initializer {
    
    let urls: [URL]
    
    init(paths: [URL]) {
        self.urls = paths
    }
    
    func perform() {

        urls.forEach { addSkipBackupAttributeToItemAtURL($0) }
    }
    
    @discardableResult
    func addSkipBackupAttributeToItemAtURL(_ url: URL) -> Bool {
        let url = NSURL.fileURL(withPath: url.path) as NSURL
        do {
            try url.setResourceValue(true, forKey: .isExcludedFromBackupKey)
            try url.setResourceValue(false, forKey: .isUbiquitousItemKey)
            return true
        } catch {
            return false
        }
    }
}
