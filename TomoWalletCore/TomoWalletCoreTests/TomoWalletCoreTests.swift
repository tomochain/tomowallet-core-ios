//
//  TomoWalletCoreTests.swift
//  TomoWalletCoreTests
//
//  Created by Admin on 8/28/19.
//  Copyright © 2019 Admin. All rights reserved.
//

import XCTest
@testable import TomoWalletCore

extension KeyStore {
    var keyWallet: Wallet? {
        return wallets.first(where: { $0.type == .encryptedKey })
    }
    
    var hdWallet: Wallet? {
        return wallets.first(where: { $0.type == .hierarchicalDeterministicWallet })
    }
}


class TomoWalletCoreTests: XCTestCase {
    
    let keyAddress = EthereumAddress(string: "0x008AeEda4D805471dF9b2A5B0f38A0C3bCBA786b")!
    let walletAddress = EthereumAddress(string: "0x32dd55E0BCF509a35A3F5eEb8593fbEb244796b1")!
    
    var dataDirectory: URL!

    override func setUp() {
        
        let fileManager = FileManager.default
        
        dataDirectory = URL(fileURLWithPath: NSTemporaryDirectory())
//        try? fileManager.removeItem(at: keyDirectory)
//        try? fileManager.createDirectory(at: keyDirectory, withIntermediateDirectories: true, attributes: nil)
//        
//        let keyURL = Bundle(for: type(of: self)).url(forResource: "key", withExtension: "json")!
//        let keyDestination = keyDirectory.appendingPathComponent("key.json")
//        
//        try? fileManager.removeItem(at: keyDestination)
//        try? fileManager.copyItem(at: keyURL, to: keyDestination)
//        
//        let walletURL = Bundle(for: type(of: self)).url(forResource: "wallet", withExtension: "json")!
//        let walletDestination = keyDirectory.appendingPathComponent("wallet.json")
//        
//        try? fileManager.removeItem(at: walletDestination)
//        try? fileManager.copyItem(at: walletURL, to: walletDestination)
        
    }
    func testLoadKeyStore() {
    }
    
    func testCreateHDWallet() throws {
        let walletCore = WalletCore(network: .Mainnet, dataDirectory: dataDirectory)
        XCTAssertEqual(walletCore.getAllWallets().count, 0)
    

    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
