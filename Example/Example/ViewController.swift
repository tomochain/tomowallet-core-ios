//
//  ViewController.swift
//  Example
//
//  Created by Admin on 8/28/19.
//  Copyright © 2019 Admin. All rights reserved.
//

import UIKit
import MBProgressHUD
import Result

class ViewController: UIViewController {
    var wallet: TomoWallet?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tomoSDK = WalletCore(network: .Mainnet)
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
       let wallets = tomoSDK.getAllWallets()
  
        tomoSDK.getWallet(address: wallets[0].getAddress()) { (result) in
            MBProgressHUD.hide(for: self.view, animated: true)
            switch result{
            case .success(let wallet):
                self.wallet = wallet
                print(self.wallet?.getAddress())
            case .failure(let error):
                print(error)
            }
        }
    }


    @IBAction func getBalance(_ sender: Any) {
        wallet?.sendToken(tokenAddress: "0x417a8c01a4ecc2b3dfd85cebe5fe34d9e0efb6ff", amount: "3", toAddress: "0x9f6b8fDD3733B099A91B6D70CDC7963ebBbd2684", completion: { (tx, error) in
            
        })
        
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

