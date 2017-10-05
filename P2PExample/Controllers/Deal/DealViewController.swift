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

extension Notification.Name {
    static let dealUpdated = Notification.Name("dealUpdated")
}

class DealViewController: UITableViewController, BankCardsViewControllerDelegate, PayDealViewControllerDelegate  {

    enum Section: Int {
        case description, requests, newRequest
    }
    
    var userTypeId: UserTypeId = .employer
    
    var deal: Deal!
    
    var requests: [DealRequest] = []
    
    var creatingRequest: DealRequest?
    
    var selectedRequest: DealRequest?
    
    var statusTimer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.loadRequests()
        
        switch userTypeId {
        case .employer:
            navigationItem.title = NSLocalizedString("Deal Employer View", comment: "")
        case .freelancer:
            navigationItem.title = NSLocalizedString("Deal Freelancer View", comment: "")
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadRequests), name: .dealUpdated, object: deal)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func postReload() {
        NotificationCenter.default.post(name: .dealUpdated, object: deal)
    }
    
    @objc func loadRequests() {
        self.requests = DataStorage.default.dealRequests(for: deal)
        self.tableView.reloadData()
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
        case .description:
            return 2
        case .newRequest:
            return 1
        case .requests:
            return max(requests.count, 1)
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        cell.textLabel?.textColor = .black
        cell.detailTextLabel?.textColor = .lightGray
        
        switch Section(rawValue: indexPath.section)! {
        case .description:
            configureCellInDescriptionSection(cell, at: indexPath)
        case .requests:
            configureCellInRequestsSection(cell, at: indexPath)
        case .newRequest:
            configureCellInAddRequestSection(cell, at: indexPath)
        }
        return cell
    }
    
    func configureCellInDescriptionSection(_ cell: UITableViewCell, at indexPath: IndexPath) {
        cell.textLabel?.text = indexPath.row == 0 ? deal.title : deal.shortDescription
        cell.selectionStyle = .none
        cell.detailTextLabel?.text = nil
    }
    
    func configureCellInRequestsSection(_ cell: UITableViewCell, at indexPath: IndexPath) {
        if requests.isEmpty {
            cell.textLabel?.textColor = .black
            cell.textLabel?.text = NSLocalizedString("No requests", comment: "")
            cell.detailTextLabel?.text = nil
            cell.selectionStyle = .none
        } else {
            let request = requests[indexPath.row]
            cell.textLabel?.text = request.freelancer.title
            cell.selectionStyle = .default
            
            switch request.stateId {
            case .created:
                cell.detailTextLabel?.text = String(format: NSLocalizedString("%@ ₽", comment: ""), request.amount.stringValue)
            case .paymentProcessing:
                cell.detailTextLabel?.text = String(format: NSLocalizedString("Payment Processing... : %@ ₽", comment: ""), request.amount.stringValue)
                cell.selectionStyle = .none
            case .paid:
                cell.detailTextLabel?.text = String(format: NSLocalizedString("Paid: %@ ₽", comment: ""), request.amount.stringValue)
            case .canceling:
                cell.detailTextLabel?.text = NSLocalizedString("Canceleing...", comment: "")
                cell.selectionStyle = .none
            case .canceled:
                cell.detailTextLabel?.text = String(format: NSLocalizedString("Canceled: %@ ₽", comment: ""), request.amount.stringValue)
                cell.selectionStyle = .none
            case .paymentError:
                cell.detailTextLabel?.text = String(format: NSLocalizedString("Payment Error: %@ ₽", comment: ""), request.amount.stringValue)
            case .completed:
                cell.detailTextLabel?.text = NSLocalizedString("Freelancer Completed", comment: "")
                cell.detailTextLabel?.textColor = view.tintColor
            case .confirming:
                cell.detailTextLabel?.text = NSLocalizedString("Confirming...", comment: "")
                cell.selectionStyle = .none
            case .payoutProcessing:
                cell.detailTextLabel?.text = NSLocalizedString("Payout Processing...", comment: "")
                cell.detailTextLabel?.textColor = .orange
                cell.selectionStyle = .none
            case .payoutProcessingError:
                cell.detailTextLabel?.text = NSLocalizedString("Payout Processing Error", comment: "")
                cell.detailTextLabel?.textColor = .red
                cell.selectionStyle = .none
            case .done:
                cell.detailTextLabel?.text = NSLocalizedString("Paid to Freelancer", comment: "")
                cell.detailTextLabel?.textColor = UIColor(red:0.298,  green:0.851,  blue:0.388, alpha:1)
                cell.selectionStyle = .none
            }
        }
    }
    
    func configureCellInAddRequestSection(_ cell: UITableViewCell, at indexPath: IndexPath) {
        cell.textLabel?.text = NSLocalizedString("Add Request", comment: "")
        cell.detailTextLabel?.text = nil
        cell.selectionStyle = .default
        cell.textLabel?.textColor = view.tintColor
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch Section(rawValue: section)! {
        case .description:
            return "" // NSLocalizedString("Description", comment: "")
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
        
        let accept: (UIAlertAction) -> Void = { (_) in
            self.selectedRequest = request
            self.presentBankCardsViewController(for: .payer)
        }
        
        let cancelDeal = UIAlertAction(title: NSLocalizedString("Cancel Deal", comment: ""), style: .destructive, handler: { (_) in
            request.stateId = .canceling
            self.postReload()
            P2PCore.deals.cancel(dealId: self.deal.id, complete: { (deal, error) in
                if let error = error {
                    self.present(error: error)
                } else {
                    request.stateId = .canceled
                    self.postReload()
                }
            })
        })
        
        switch request.stateId {
        case .created:
            alert.addAction(UIAlertAction(title: NSLocalizedString("Accept", comment: ""), style: .default, handler: accept))
        case .paymentProcessing:
            return
        case .paid:
            alert.addAction(cancelDeal)
        case .canceling:
            return
        case .canceled:
            return
        case .paymentError:
            alert.addAction(UIAlertAction(title: NSLocalizedString("Try again", comment: ""), style: .default, handler: accept))
            alert.addAction(cancelDeal)
        case .completed:
            alert.addAction(UIAlertAction(title: NSLocalizedString("Confirm Completion", comment: ""), style: .default, handler: { (_) in
                request.stateId = .confirming
                self.postReload()
                P2PCore.deals.complete(dealId: self.deal.id, complete: { [weak self] (deal, error) in
                    if let error = error {
                        self?.present(error: error)
                        request.stateId = .completed
                        self?.postReload()
                    } else {
                        self?.checkStatus()
                    }
                })
            }))
        case .confirming:
            return
        case .payoutProcessing:
            return
        case .payoutProcessingError:
            return
        case .done:
            return
        }
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Dismiss", comment: ""), style: .cancel, handler: nil))
        
        present(alert, animated: true)
    }
    
    func presentFreelancerAlert(for request: DealRequest) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        switch request.stateId {
        case .created:
            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel Request", comment: ""), style: .destructive, handler: { (_) in
                DataStorage.default.cancel(request: request)
                self.postReload()
            }))
        case .paymentProcessing:
            return
        case .paid:
            alert.addAction(UIAlertAction(title: NSLocalizedString("Complete", comment: ""), style: .default, handler: { (_) in
                request.stateId = .completed
                self.postReload()
            }))
        case .canceling:
            return
        case .canceled:
            return
        case .paymentError:
            return
        case .completed:
            return
        case .confirming:
            return
        case .payoutProcessing:
            return
        case .payoutProcessingError:
            return
        case .done:
            return
        }
        
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
    
    func presentBankCardsViewController(for owner: BankCardsViewController.Owner) {
        
        let vc = BankCardsViewController(owner: owner, delegate: self)
        
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
            self.postReload()
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
    
    func bankCardsViewControllerHeaderTitleForBankCardsSection(_ vc: BankCardsViewController) -> String {
        return NSLocalizedString("Select Card", comment: "")
    }
    
    func bankCardsViewControllerFooterTitleForBankCardsSection(_ vc: BankCardsViewController) -> String {
        switch vc.owner {
        case .benificiary:
            return NSLocalizedString("Select card for receiving payment after deal completion", comment: "")
        case .payer:
            return NSLocalizedString("Select card to make deal payment", comment: "")
        }
    }
    
    func createP2PDeal(with employerCard: BankCard?) {
        
        guard let request = selectedRequest else { return }
        
        P2PCore.deals.create(
            dealId: self.deal.id,
            beneficiaryId: request.freelancer.id,
            payerCardId: employerCard?.cardId ?? 0,
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
        vc.delegate = self
        
        if !redirectToCardAddition {
            let alert = UIAlertController(title: NSLocalizedString("Enter CVV", comment: ""), message: nil, preferredStyle: .alert)
            
            alert.addTextField(configurationHandler: { (textField) in
                textField.placeholder = "CVV/CVC - 3 digits"
                textField.keyboardType = .numberPad
            })
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Pay", comment: ""), style: .default, handler: { (_) in
                let cvv = alert.textFields?[0].text ?? ""
                if cvv.characters.count != 3 {
                    self.presentPaymentViewController(redirectToCardAddition: false)
                } else {
                    vc.authData = cvv
                }
                self.present(payment: vc)
            }))
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))
            
            self.present(alert, animated: true)
        } else {
            self.present(payment: vc)
        }
    }
    
    func present(payment vc: PayDealViewController) {
        let nc = UINavigationController(rootViewController: vc)
        present(nc, animated: true, completion: nil)
    }
    
    func payDealViewControllerComplete(_ vc: PayDealViewController) {
        vc.dismiss(animated: true) { }
        checkStatus()
    }
    
    func watchStatus() {
        statusTimer?.invalidate()
        statusTimer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(checkStatus), userInfo: nil, repeats: false)
    }
    
    @objc func checkStatus() {
        P2PCore.deals.status(dealId: deal.id) { [weak self] (deal, error) in
            if let error = error {
                self?.present(error: error)
            } else if let deal = deal {
                guard let request = self?.selectedRequest else { return }
                switch deal.dealStateId {
                case DealStateIdPaymentProcessing:
                    request.stateId = .paymentProcessing
                    self?.watchStatus()
                case DealStateIdPaymentProcessError:
                    request.stateId = .paymentError
                case DealStateIdPaid:
                    request.stateId = .paid
                case DealStateIdPayoutProcessing:
                    request.stateId = .payoutProcessing
                    self?.watchStatus()
                case DealStateIdPayoutProcessError:
                    request.stateId = .payoutProcessingError
                case DealStateIdCompleted:
                    request.stateId = .done
                default:
                    let error = NSError.error(deal.dealStateId)
                    self?.present(error: error)
                }
                self?.postReload()
            }
        }
    }
    
}

