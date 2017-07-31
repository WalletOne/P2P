//
//  DealViewController.swift
//  P2P_iOS
//
//  Created by Vitaliy Kuzmenko on 31/07/2017.
//  Copyright © 2017 Wallet One. All rights reserved.
//

import UIKit

class DealViewController: UITableViewController {

    enum Section: Int {
        case shortDescription, fullDescription, requests, newRequest
    }
    
    var userTypeId: UserTypeId = .employer
    
    var deal: Deal!
    
    var requests: [DealRequest] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = deal.title
        self.loadRequests()
    }
    
    func loadRequests() {
        self.requests = DataStorage.default.dealRequests(for: deal)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        switch userTypeId {
        case .employer:
            return 3
        case .freelancer:
            if requests.contains(where: {$0.freelancer == DataStorage.default.freelancer }) {
                return 3
            } else {
                return 4
            }
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section(rawValue: section)! {
        case .shortDescription, .fullDescription, .newRequest:
            return 1
        case .requests:
            return max(requests.count, 1)
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        cell.textLabel?.textColor = .black
        
        switch Section(rawValue: indexPath.section)! {
        case .shortDescription:
            cell.textLabel?.text = deal.shortDescription
            cell.selectionStyle = .none
            cell.detailTextLabel?.text = nil
        case .fullDescription:
            cell.textLabel?.text = deal.fullDescription
            cell.selectionStyle = .none
            cell.detailTextLabel?.text = nil
        case .requests:
            if requests.isEmpty {
                cell.textLabel?.text = NSLocalizedString("No requests", comment: "")
                cell.detailTextLabel?.text = nil
                cell.selectionStyle = .none
            } else {
                let request = requests[indexPath.row]
                cell.textLabel?.text = request.freelancer.title
                cell.detailTextLabel?.text = String(format: "$%@", request.amount.stringValue)
                cell.selectionStyle = .default
            }
        case .newRequest:
            cell.textLabel?.text = NSLocalizedString("Add Request", comment: "")
            cell.detailTextLabel?.text = nil
            cell.selectionStyle = .default
            cell.textLabel?.textColor = view.tintColor
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch Section(rawValue: section)! {
        case .shortDescription:
            return NSLocalizedString("Short description", comment: "")
        case .fullDescription:
            return NSLocalizedString("Full description", comment: "")
        case .requests:
            return NSLocalizedString("Freelancer requests", comment: "")
        case .newRequest:
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch Section(rawValue: indexPath.section)! {
        case .requests where !requests.isEmpty:
            didSelectRequest(at: indexPath)
        case .newRequest:
            didSelectNewRequest()
        default:
            break
        }
    }
    
    func didSelectRequest(at indexPath: IndexPath) {
        let request = requests[indexPath.row]
        switch userTypeId {
        case .employer:
            presentEmployerAlert(for: request)
        case .freelancer:
            presentFreelancerAlert(for: request)
        }
    }
    
    func presentEmployerAlert(for request: DealRequest) {
        
    }
    
    func presentFreelancerAlert(for request: DealRequest) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel Request", comment: ""), style: .destructive, handler: { (_) in
            DataStorage.default.cancel(request: request)
            self.loadRequests()
            self.tableView.reloadData()
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Dismiss", comment: ""), style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    
    var creatingRequest: DealRequest?
    
    func didSelectNewRequest() {
        let alert = UIAlertController(title: NSLocalizedString("Create Request", comment: ""), message: NSLocalizedString("What amount you do this deal?", comment: ""), preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.placeholder = NSLocalizedString("Amount", comment: "")
        }

        alert.addAction(UIAlertAction(title: NSLocalizedString("Create", comment: ""), style: .default, handler: { (action) in
            let amount = NSDecimalNumber(string: alert.textFields?[0].text)
            self.creatingRequest = DealRequest(deal: self.deal, freelancer: DataStorage.default.freelancer, amount: amount)
            self.checkNewRequest()
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    
    func checkNewRequest() {
        if creatingRequest!.amount.stringValue == "NaN" {
            self.didSelectNewRequest()
        } else {
            DataStorage.default.dealRequests.append(creatingRequest!)
            creatingRequest = nil
            loadRequests()
            self.tableView.reloadData()
        }
    }

}
