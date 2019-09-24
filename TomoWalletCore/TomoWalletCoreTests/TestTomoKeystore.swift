//
//  TestImportWallet.swift
//  TomoWalletCoreTests
//
//  Created by Can Dang on 9/23/19.
//  Copyright © 2019 Admin. All rights reserved.
//

import XCTest
@testable import TomoWalletCore

class TestImportWallet: XCTestCase {
    let words = "ripple scissors kick mammal hire column oak again sun offer wealth tomorrow wagon turn fatal"
    let passphrase = "TREZOR"
    let password = "password"
    
    func testSignHash() throws {
        let privateKey = PrivateKey(data: Data(hexString: "D30519BCAE8D180DBFCC94FE0B8383DC310185B0BE97B4365083EBCECCD75759")!)!
        let key = try KeystoreKey(password: password, key: privateKey, coin: .tomo)
        let wallet = Wallet(keyURL: URL(fileURLWithPath: "/"), key: key)
        let account = try wallet.getAccount(password: password)
        
        let hash = Data(hexString: "3F891FDA3704F0368DAB65FA81EBE616F4AA2A0854995DA4DC0B59D2CADBD64F")!
        let result = try account.sign(hash: hash, password: password)
        
        let publicKey = privateKey.publicKey(for: .tomo)
        XCTAssertEqual(result.count, 65)
        XCTAssertTrue(Crypto.verify(signature: result, message: hash, publicKey: publicKey.data))
    }

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
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
