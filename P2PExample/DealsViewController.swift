//
//  DealsViewController.swift
//  P2P_iOS
//
//  Created by Vitaliy Kuzmenko on 31/07/2017.
//  Copyright © 2017 Wallet One. All rights reserved.
//

import UIKit
import P2PUI

enum UserTypeId {
    case employer, freelancer
}

class DealsViewController: UITableViewController {

    @IBOutlet var plusBarButton: UIBarButtonItem!
    
    var userTypeId: UserTypeId = .employer
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        configurePlusButton()
    }
    
    func configurePlusButton() {
        switch userTypeId {
        case .employer:
            navigationItem.rightBarButtonItem = plusBarButton
        default:
            navigationItem.rightBarButtonItem = nil
        }
    }
    
    var creatingDeal: Deal?
    
    @IBAction func createDeal() {
        let alert = UIAlertController(title: NSLocalizedString("Create Deal", comment: ""), message: NSLocalizedString("Fill all fields!", comment: ""), preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.placeholder = NSLocalizedString("Title", comment: "")
            textField.text = self.creatingDeal?.title
        }
        alert.addTextField { (textField) in
            textField.placeholder = NSLocalizedString("Short Description", comment: "")
            textField.text = self.creatingDeal?.shortDescription
        }
        alert.addTextField { (textField) in
            textField.placeholder = NSLocalizedString("Full Description", comment: "")
            textField.text = self.creatingDeal?.fullDescription
        }
        alert.addAction(UIAlertAction(title: NSLocalizedString("Create", comment: ""), style: .default, handler: { (action) in
            if self.creatingDeal == nil {
                self.creatingDeal = Deal(employer: DataStorage.default.employer)
                self.creatingDeal!.id = NSUUID().uuidString
            }
            self.creatingDeal!.title = alert.textFields?[0].text ?? ""
            self.creatingDeal?.shortDescription = alert.textFields?[1].text ?? ""
            self.creatingDeal?.fullDescription = alert.textFields?[2].text ?? ""
            
            self.checkNewDeal()
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    
    func checkNewDeal() {
        
        if creatingDeal!.title.isEmpty || creatingDeal!.shortDescription.isEmpty || creatingDeal!.fullDescription.isEmpty {
            self.createDeal()
        } else {
            DataStorage.default.deals.append(creatingDeal!)
            creatingDeal = nil
            self.tableView.reloadData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let cell = sender as! UITableViewCell
        let indexPath = tableView.indexPath(for: cell)
        let vc = segue.destination as! DealViewController
        vc.deal = DataStorage.default.deals[indexPath!.row]
        vc.userTypeId = userTypeId
    }
    
    // MARK: - TableView
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DataStorage.default.deals.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let deal = DataStorage.default.deals[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "deal", for: indexPath)
        cell.textLabel?.text = deal.title
        return cell
    }

}
