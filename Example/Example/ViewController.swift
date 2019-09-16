//
//  ViewController.swift
//  Example
//
//  Created by Admin on 8/28/19.
//  Copyright © 2019 Admin. All rights reserved.
//

import UIKit
import PromiseKit
import Result
import TomoWalletCore

class ViewController: UIViewController {
    var wallet: TomoWallet?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tomoSDK = WalletCore(network: .Mainnet)
        tomoSDK.importWallet(recoveryPhase: "ordinary chest giant insane van denial twin music curve offer umbrella spot") { (result) in
         
            switch result{
            case .success(let wallet):
                self.wallet = wallet
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        tomoSDK.createWallet { (result) in
            switch result{
            case .success(let wallet):
                print(wallet)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        tomoSDK.importAddressOnly(address: "0x9f6b8fDD3733B099A91B6D70CDC7963ebBbd2684") { (result) in
            switch result{
            case .success(let wallet):
                print(wallet)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        tomoSDK.importWallet(hexPrivateKey: "0x4745044ccdb778fb6d2d999c561f4329deb57ee3628672d7a2954a53e20b167e") { (result) in
            switch result{
            case .success(let wallet):
                print(wallet)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        

    }

    @IBAction func sendAction(_ sender: Any) {
        firstly {
            wallet!.makeTomoTransaction(toAddress: "0x9f6b8fDD3733B099A91B6D70CDC7963ebBbd2684", amount: "95.9999748")
            }.done{(tx) in
                print(tx)
            }.catch{ (error) in
                print(error.localizedDescription)
        }
        
    }
    
    @IBAction func getBalance(_ sender: Any) {
        firstly{
            self.wallet!.getTokenInfo(contract: "0x357dde188fe7b6abb0b8b6a4afe917cdf4b7080b")
            }.then { (token) -> Promise<SignTransaction> in
                return self.wallet!.makeTokenTransaction(token: token, toAddress: "0x9f6b8fDD3733B099A91B6D70CDC7963ebBbd2684", amount: "0.1")
            }.done { (signTX) in
                print(signTX)
            }.catch { (error) in
                print(error.localizedDescription)
        }
    }
}

//firstly {
//    wallet!.sendToken(contract: "0x9f6b8fDD3733B099A91B6D70CDC7963ebBbd2684", toAddress: "0x9f6b8fDD3733B099A91B6D70CDC7963ebBbd2684", amount: "1")
//    }.done { (signTX) in
//        print(signTX)
//    }.catch { (error) in
//        print(error.localizedDescription)
//}
//firstly{
//    wallet!.makeTomoTransaction(toAddress: "0x9f6b8fDD3733B099A91B6D70CDC7963ebBbd2684", amount: "20")
//    }.done { (signTX) in
//        print(signTX)
//    }.catch { (error) in
//        print(error.localizedDescription)
//}

