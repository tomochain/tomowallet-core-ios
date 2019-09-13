//
//  ViewController.swift
//  Example
//
//  Created by Admin on 8/28/19.
//  Copyright © 2019 Admin. All rights reserved.
//

import UIKit
import MBProgressHUD
import PromiseKit

class ViewController: UIViewController {
    var wallet: TomoWallet?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tomoSDK = WalletCore(network: .Mainnet)
        MBProgressHUD.showAdded(to: self.view, animated: true)
        tomoSDK.importWallet(recoveryPhase: "ordinary chest giant insane van denial twin music curve offer umbrella spot") { (result) in
            MBProgressHUD.hide(for: self.view, animated: true)
            switch result{
            case .success(let wallet):
                print(wallet.getAddress())
                self.wallet = wallet
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        
//       let wallets = tomoSDK.getAllWallets()
//
//        tomoSDK.getWallet(address: wallets[0].getAddress()) { (result) in
//            MBProgressHUD.hide(for: self.view, animated: true)
//            switch result{
//            case .success(let wallet):
//                self.wallet = wallet
//                print(self.wallet?.getAddress())
//            case .failure(let error):
//                print(error)
//            }
//        }
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
        
        firstly {
            wallet!.getTomoBabance()
            }.done{(balance) in
                print(balance)
            }.catch{ (error) in
                print(error.localizedDescription)
        }
//        firstly{
//            wallet!.getTokenBalance(contract: "0xedabb249894d8bd3ca4a2ec2b76ce29e9619e43d")
//            }.done { (balance) in
//                print(balance)
//            }.catch { (error) in
//                print(error.localizedDescription)
//        }
//
//
        firstly{
            wallet!.sendToken(contract: "0x9f6b8fDD3733B099A91B6D70CDC7963ebBbd2684", toAddress: "0x9f6b8fDD3733B099A91B6D70CDC7963ebBbd2684", amount: "10")
            }.done { (sentTX) in
                print(sentTX)
            }.catch { (error) in
                print(error.localizedDescription)
        }
//
//        wallet?.sendToken(tokenAddress: "0x417a8c01a4ecc2b3dfd85cebe5fe34d9e0efb6ff", amount: "3", toAddress: "0x9f6b8fDD3733B099A91B6D70CDC7963ebBbd2684", completion: { (tx, error) in
//            print(tx)
//
//        })
        
//        wallet?.getTokenInfo(token: "0xedabb249894d8bd3ca4a2ec2b76ce29e9619e43d", completion: { (token, error) in
//            print(token)
//        })
//        wallet?.getTokenBalance(tokenAddress: "0x8a2b61a7a1f7ddfa040267b67d2e347d8f08e66b", decimals: nil, completion: { (value, error) in
//            print( value)
//
//        })
        
//        wallet?.sendTomo(amount: "1", toAddress: "0x9f6b8fDD3733B099A91B6D70CDC7963ebBbd2684", completion: { (tx, error) in
//            print(tx)
//        })
//        wallet?.getTomoBabance { (resutl) in
//            switch resutl{
//            case .success(let balance):
//                print(balance)
//            case .failure(let error):
//                print(error)
//            }
//        }
    }
}

