//
//  WalletTest.swift
//  TomoWalletCoreTests
//
//  Created by Can Dang on 9/20/19.
//  Copyright © 2019 Admin. All rights reserved.
//

import XCTest
@testable import TomoWalletCore

class WalletTest: XCTestCase {
    
    func testSign() {
        let hash = Data(hexString: "3F891FDA3704F0368DAB65FA81EBE616F4AA2A0854995DA4DC0B59D2CADBD64F")!
        let privateKey = Data(hexString: "D30519BCAE8D180DBFCC94FE0B8383DC310185B0BE97B4365083EBCECCD75759")!
        let signature = Crypto.sign(hash: hash, privateKey: privateKey)
        let publicKey = Crypto.getPublicKey(from: privateKey)
        
        XCTAssertEqual(signature.count, 65)
        XCTAssertEqual(signature.hexString, "e56cfc6bddb0f803ee41c163816c3aa924ea0aae937294daf6a55f948aab8b463746cd528a3ad0102b431d7c7cecec7d92b910fe57c1213514c12206c41f1fef00")
        XCTAssertTrue(Crypto.verify(signature: signature, message: hash, publicKey: publicKey))
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
