// Copyright © 2017-2018 Trust.
//
// This file is part of Trust. The full Trust copyright notice, including
// terms governing use, modification, and redistribution, is contained in the
// file LICENSE at the root of the source code distribution tree.

@testable import TomoWalletCore
import XCTest

class PrivateKeyTests: XCTestCase {
    func testCreateNew() {
        let privateKey = PrivateKey()
        XCTAssertTrue(PrivateKey.isValid(data: privateKey.data))
    }

    func testCreateFromInvalid() {
        let privateKey = PrivateKey(data: Data(hexString: "0xdeadbeef")!)
        XCTAssertNil(privateKey)
    }

    func testIsValidString() {
        let valid = PrivateKey.isValid(data: Data(hexString: "4745044ccdb778fb6d2d999c561f4329deb57ee3628672d7a2954a53e20b167e")!)
        XCTAssert(valid)
    }

    func testPublicKey() {
        let privateKey = PrivateKey(data: Data(hexString: "4745044ccdb778fb6d2d999c561f4329deb57ee3628672d7a2954a53e20b167e")!)!
        let publicKey = privateKey.publicKey(for: .tomo)
        XCTAssertEqual(publicKey.address.description.lowercased(), "0x36d0701257ab74000588e6bdaff014583e03775b".lowercased())
    }


}
