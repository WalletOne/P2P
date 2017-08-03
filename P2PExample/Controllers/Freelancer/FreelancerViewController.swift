//
//  FreelancerViewController.swift
//  P2P_iOS
//
//  Created by Vitaliy Kuzmenko on 02/08/2017.
//  Copyright © 2017 Wallet One. All rights reserved.
//

import UIKit
import P2PCore
import P2PUI

class FreelancerViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let freelancer = Freelancer()
        freelancer.id = "alinakuzmenko" // NSUUID().uuidString
        freelancer.title = "Alina Kuzmenko"
        freelancer.phoneNumber = "79287654321"
        
        DataStorage.default.freelancer = freelancer
        
        P2PCore.setBenificiary(id: freelancer.id, title: freelancer.title, phoneNumber: freelancer.phoneNumber)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        switch segue.identifier! {
        case "DealsViewController":
            let vc = segue.destination as! DealsViewController
            vc.userTypeId = .freelancer
        default:break
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let bankCardsIndexPath = IndexPath(row: 0, section: 1)
        let payoutsIndexPath = IndexPath(row: 1, section: 1)
        switch indexPath {
        case bankCardsIndexPath:
            presentBankCards()
        case payoutsIndexPath:
            presentPayouts()
        default:
            break
        }
    }
    
    func presentBankCards() {
        let vc = BankCardsViewController(owner: .benificiary)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func presentPayouts() {
        let vc = PayoutsViewController(dealId: nil)
        navigationController?.pushViewController(vc, animated: true)
    }

}
