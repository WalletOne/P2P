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

class ViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        DataStorage.default.fillTestData()
        
        let fl = DataStorage.default.freelancer!
        let em = DataStorage.default.employer!
        
        // Core initialization
        P2PCore.setPlatform(id: "testplatform", signatureKey: "TestPlatformSignatureKey")
        
        // Set this data when user login
        P2PCore.setBenificiary(id: fl.id, title: fl.title, phoneNumber: fl.phoneNumber)
        P2PCore.setPayer(id: em.id, title: em.title, phoneNumber: em.phoneNumber)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! DealsViewController
        
        super.prepare(for: segue, sender: sender)
        switch segue.identifier! {
        case "Employer":
            vc.userTypeId = .employer
        case "Freelancer":
            vc.userTypeId = .freelancer
        default:
            break
        }
    }

}

