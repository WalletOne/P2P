//
//  EmployerViewController.swift
//  P2P_iOS
//
//  Created by Vitaliy Kuzmenko on 02/08/2017.
//  Copyright © 2017 Wallet One. All rights reserved.
//

import UIKit
import P2PCore
import P2PUI

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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let bankCardsIndexPath = IndexPath(row: 0, section: 1)
        let refundsIndexPath = IndexPath(row: 1, section: 1)
        switch indexPath {
        case bankCardsIndexPath:
            presentBankCards()
        case refundsIndexPath:
            presentRefunds()
        default:
            break
        }
    }
    
    func presentBankCards() {
        let vc = BankCardsViewController(owner: .payer)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func presentRefunds() {
        let vc = RefundsViewController(dealId: nil)
        navigationController?.pushViewController(vc, animated: true)
    }

}
