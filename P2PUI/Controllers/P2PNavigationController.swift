//
//  P2PNavigationController.swift
//  P2P_iOS
//
//  Created by Vitaliy Kuzmenko on 17/07/2017.
//  Copyright © 2017 Wallet One. All rights reserved.
//

import UIKit
import P2PCore

@objc public enum P2PViewControllerTypeId: Int {
    case bankCards
}

let kBundle = Bundle(identifier: "com.walletone.ios.P2PUI")

//@objc public class P2PNavigationController: UINavigationController {
//    
//    public convenience init(typeId: P2PViewControllerTypeId) {
//        
//        let vc: UIViewController
//        
//        switch typeId {
//        case .bankCards:
//            vc = BankCardsViewController(nibName: "BankCardsViewController", bundle: kBundle)
//        }
//        
//        self.init(rootViewController: vc)
//    }
//    
//}
