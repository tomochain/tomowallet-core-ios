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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tomoSDK = TomoSDK()
        MBProgressHUD.showAdded(to: self.view, animated: true)
        tomoSDK.createWallet { (result) in
            MBProgressHUD.hide(for: self.view, animated: true)
            switch result{
                case.success(let wallet):
                print(wallet)
            case .failure(let error):
                print(error.errorDescription ?? "")
                
            }
        }
       
    }


}

