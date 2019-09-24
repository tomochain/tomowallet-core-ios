//
//  TomoWalletCoreTests.swift
//  TomoWalletCoreTests
//
//  Created by Admin on 9/24/19.
//  Copyright © 2019 Admin. All rights reserved.

import TrezorCrypto
@testable import TomoWalletCore
import XCTest

class HDWalletTests: XCTestCase {
    let words = "ordinary chest giant insane van denial twin music curve offer umbrella spot"
    let passphrase = "TomoChain"

    func testSeed() {
        let wallet = HDWallet(mnemonic: words, passphrase: passphrase)
        XCTAssertEqual(wallet.seed.hexString, "3b8379e4d7bd8369f67f57d9e871b481e0d6e30ef84d99b34965c175fd89fd579389115327968504eb1cc994411aec987561292ca0de00d5887fc0cbf3ab2776")
    }
    func testSeedNoPassword() {
        let wallet = HDWallet(mnemonic: words, passphrase: "")
        print(wallet.seed.hexString)
        XCTAssertEqual(wallet.seed.hexString, "6c35edabd637577065b3456d26449b24f3813f075db7ef95299389b6b8f847f697dd498620cb1aba4c0f897b87f5326ccf6326ca0bcb52840614e7dce89e3aa8")
    }
    func testPrivateKeyNoPassword() {
        let wallet = HDWallet(mnemonic: words)
        XCTAssertEqual(wallet.getKey(at: Coin.tomo.derivationPath(at: 0)).description, "4745044ccdb778fb6d2d999c561f4329deb57ee3628672d7a2954a53e20b167e")
    }

    func testAddress() {
        let wallet = HDWallet(mnemonic: words)
        let key0 = wallet.getKey(at: Coin.tomo.derivationPath(at: 0))
        let key1 = wallet.getKey(at: Coin.tomo.derivationPath(at: 1))
        print(key0.publicKey(for: .ethereum).address.description)
        XCTAssertEqual(key0.publicKey(for: .tomo).address.description.lowercased(), "0x36d0701257ab74000588e6bdaff014583e03775b".lowercased())
        XCTAssertEqual(key1.publicKey(for: .tomo).address.description.lowercased(), "0x0c95b6ba8761b6c8d4d60747220932b9d4ca4334".lowercased())
        
    }


}
