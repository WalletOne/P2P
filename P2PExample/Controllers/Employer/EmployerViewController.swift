//
//  EmployerViewController.swift
//  P2P_iOS
//
//  Created by Vitaliy Kuzmenko on 02/08/2017.
//  Copyright © 2017 Wallet One. All rights reserved.
//

import UIKit
import P2PCore

class EmployerViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let employer = Employer()
        employer.id = "vitaliykuzmenko" // NSUUID().uuidString
        employer.title = "Vitaliy Kuzmenko"
        employer.phoneNumber = "79281234567"
        
        DataStorage.default.employer = employer
        
        P2PCore.setPayer(id: employer.id, title: employer.title, phoneNumber: employer.phoneNumber)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        switch segue.identifier! {
        case "DealsViewController":
            let vc = segue.destination as! DealsViewController
            vc.userTypeId = .employer
        default:break
        }
    }

}
