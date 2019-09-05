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
        wallet?.getTokenBalance(tokenAddress: "0x8a2b61a7a1f7ddfa040267b67d2e347d8f08e66b", decimals: nil, completion: { (value, error) in
            
        })
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

