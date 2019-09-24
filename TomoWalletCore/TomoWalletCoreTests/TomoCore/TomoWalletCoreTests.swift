//
//  TomoWalletCoreTests.swift
//  TomoWalletCoreTests
//
//  Created by Admin on 8/28/19.
//  Copyright © 2019 Admin. All rights reserved.
//

import XCTest
@testable import TomoWalletCore
@testable import PromiseKit
@testable import Result

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
    
    func testCreateHDWallet() {
        let walletCore = WalletCore(network: .Mainnet, dataDirectory: dataDirectory)
      
        let expectation = XCTestExpectation(description: "Download apple.com home page")
        walletCore.createWallet { (result) in
            // Make sure we downloaded some data.
            XCTAssertNotNil(result, "No data was downloaded.")
            // Fulfill the expectation to indicate that the background task has finished successfully.
            switch result{
            case .success(let wallet):
                 XCTAssertEqual(wallet.getAddress().count,32)
            case .failure(let error):
                XCTFail("Error: \(error.localizedDescription)")
            }
             expectation.fulfill()
        }
        // Wait until the expectation is fulfilled, with a timeout of 10 seconds.
        wait(for: [expectation], timeout: 600.0)
    }
    func testImportPrivateKey() throws {
        let keyStore = try KeyStore(keyDirectory: dataDirectory.appendingPathComponent("keystore"))
        let privateKey = PrivateKey(data: Data(hexString: "9cdb5cab19aec3bd0fcd614c5f185e7a1d97634d4225730eba22497dc89a716c")!)!
        
        let wallet = try keyStore.import(privateKey: privateKey, password: "password", coin: .tomo)
        
        XCTAssertEqual(wallet.accounts.count, 1)
        
        
        let account = try wallet.getAccount(password: "password")
        print(account.address.description)
        XCTAssertNotNil(keyStore.keyWallet)
        XCTAssertNoThrow(try account.sign(hash: Data(repeating: 0, count: 32), password: "password"))
        
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
