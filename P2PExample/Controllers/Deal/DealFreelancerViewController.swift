//
//  DealFreelancerViewController.swift
//  P2P_iOS
//
//  Created by Vitaliy Kuzmenko on 02/08/2017.
//  Copyright © 2017 Wallet One. All rights reserved.
//

import UIKit
import P2PCore
import P2PUI

class DealFreelancerViewController: DealViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        // check existing freelancer request for show or hide add request cell 
        if requests.contains(where: { $0.freelancer == DataStorage.default.freelancer }) {
            return 2
        } else {
            return 3
        }
    }


}
