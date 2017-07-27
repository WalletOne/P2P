//
//  ViewController.swift
//  P2PExample
//
//  Created by Vitaliy Kuzmenko on 17/07/2017.
//  Copyright © 2017 Wallet One. All rights reserved.
//

import UIKit
import P2PUI
import P2PCore

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        P2PCore.setPlatform(id: "testplatform", signatureKey: "TestPlatformSignatureKey")
        P2PCore.setBenificiary(id: "vitkuzmenko", title: "Виталий Кузьменко", phoneNumber: "79286634400")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let vc = BankCardsViewController(owner: .benificiary)
        
        let nvc = UINavigationController(rootViewController: vc)
        present(nvc, animated: true, completion: nil)
    }


}

