//
//  DealViewController.swift
//  P2P_iOS
//
//  Created by Vitaliy Kuzmenko on 31/07/2017.
//  Copyright © 2017 Wallet One. All rights reserved.
//

import UIKit
import P2PCore
import P2PUI

class DealViewController: UITableViewController {

    enum Section: Int {
        case description, requests, newRequest
    }
    
    var userTypeId: UserTypeId = .employer
    
    var deal: Deal!
    
    var requests: [DealRequest] = []
    
    var creatingRequest: DealRequest?
    
    var selectedRequest: DealRequest?
    
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
            return 2
        case .freelancer:
            if requests.contains(where: {$0.freelancer == DataStorage.default.freelancer }) {
                return 2
            } else {
                return 3
            }
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section(rawValue: section)! {
        case .description, .newRequest:
            return 1
        case .requests:
            return max(requests.count, 1)
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        cell.textLabel?.textColor = .black
        
        switch Section(rawValue: indexPath.section)! {
        case .description:
            cell.textLabel?.text = deal.shortDescription
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
                cell.detailTextLabel?.text = String(format: "%@ ₽", request.amount.stringValue)
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
        case .description:
            return NSLocalizedString("Short description", comment: "")
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
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Accept", comment: ""), style: .default, handler: { (_) in
            self.selectedRequest = request
            self.presentBankCardsViewController(for: .payer)
        }))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Dismiss", comment: ""), style: .cancel, handler: nil))
        
        present(alert, animated: true)
    }
    
    func createDeal(employerCardId: Int?) {
        
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
            self.presentBankCardsViewController(for: .benificiary)
        }
    }

}

extension DealViewController: BankCardsViewControllerDelegate {
    
    func presentBankCardsViewController(for owner: BankCardsViewController.Owner) {
        
        let vc = BankCardsViewController(owner: owner)
        vc.delegate = self
        
        let nc = UINavigationController(rootViewController: vc)
        
        present(nc, animated: true, completion: nil)
    }
    
    func bankCardsViewController(_ vc: BankCardsViewController, didSelect bankCard: BankCard) {
        vc.dismiss(animated: true, completion: nil)
        switch vc.owner {
        case .benificiary:
            creatingRequest?.freelancerCardId = bankCard.cardId
            DataStorage.default.dealRequests.append(creatingRequest!)
            creatingRequest = nil
            loadRequests()
            self.tableView.reloadData()
        case .payer:
            createP2PDeal(with: bankCard)
            break
        }
    }
    
    func bankCardsViewControllerDidSelectLinkNew(_ vc: BankCardsViewController) {
        vc.dismiss(animated: true) { 
            self.createP2PDeal(with: nil)
        }
    }
    
    func createP2PDeal(with employerCard: BankCard?) {
        
        guard let request = selectedRequest else { return }
        
        P2PCore.deals.create(
            dealId: self.deal.id,
            payerId: self.deal.employer.id,
            beneficiaryId: request.freelancer.id,
            payerPhoneNumber: self.deal.employer.phoneNumber,
            payerCardId: employerCard?.cardId,
            beneficiaryCardId: request.freelancerCardId,
            amount: request.amount,
            currencyId: .rub,
            shortDescription: self.deal.shortDescription,
            fullDescription: self.deal.fullDescription,
            deferPayout: true,
            complete: { (deal, error) in
                if let error = error {
                    self.present(error: error)
                } else  if deal != nil {
                    self.presentPaymentViewController(redirectToCardAddition: employerCard == nil)
                }
            }
        )
    }
    
    func presentPaymentViewController(redirectToCardAddition: Bool) {
        
        let vc = PayDealViewController(dealId: deal.id, redirectToCardAddition: redirectToCardAddition)
        
        if !redirectToCardAddition {
            let alert = UIAlertController(title: NSLocalizedString("Enter CVV", comment: ""), message: nil, preferredStyle: .alert)
            alert.addTextField(configurationHandler: { (textField) in
                textField.placeholder = "CVV/CVC - 3 digits"
                textField.keyboardType = .numberPad
            })
            alert.addAction(UIAlertAction(title: NSLocalizedString("Next", comment: ""), style: .default, handler: { (_) in
                let cvv = alert.textFields?[0].text ?? ""
                if cvv.characters.count != 3 {
                    self.presentPaymentViewController(redirectToCardAddition: false)
                } else {
                    vc.authData = cvv
                }
                self.present(payment: vc)
            }))
            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .default, handler: nil))
            
            self.present(alert, animated: true)
        } else {
            self.present(payment: vc)
        }
    }
    
    func present(payment vc: PayDealViewController) {
        
        let nc = UINavigationController(rootViewController: vc)
        
        present(nc, animated: true, completion: nil)
        
    }
    
}

