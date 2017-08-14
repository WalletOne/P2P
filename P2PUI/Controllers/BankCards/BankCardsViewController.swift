//
//  BankCardsTableViewController.swift
//  P2P_iOS
//
//  Created by Vitaliy Kuzmenko on 26/07/2017.
//  Copyright © 2017 Wallet One. All rights reserved.
//

import UIKit
import P2PCore

@objc public protocol BankCardsViewControllerDelegate: NSObjectProtocol {
    @objc optional func bankCardsViewControllerHeaderTitleForBankCardsSection(_ vc: BankCardsViewController) -> String
    @objc optional func bankCardsViewControllerFooterTitleForBankCardsSection(_ vc: BankCardsViewController) -> String
    
    @objc optional func bankCardsViewControllerHeaderTitleForLinkNewCardSection(_ vc: BankCardsViewController) -> String
    @objc optional func bankCardsViewControllerFooterTitleForLinkNewCardSection(_ vc: BankCardsViewController) -> String
    
    func bankCardsViewController(_ vc: BankCardsViewController, didSelect bankCard: BankCard)
    
    // Called only when owner is .payer
    func bankCardsViewControllerDidSelectLinkNew(_ vc: BankCardsViewController)
}

@objc open class BankCardsViewController: P2PViewController, TableStructuredViewController {
    
    @objc public enum Owner: Int {
        case benificiary, payer
    }
    
    @IBOutlet weak open var tableView: UITableView!
    
    lazy var cancelButton: UIBarButtonItem = {
        return UIBarButtonItem(title: NSLocalizedString("Cancel", comment: ""), style: .done, target: self, action: #selector(dismissViewController))
    }()
    
    lazy var tableController: BankCardsTableViewController = { return .init(vc: self) }()
    
    public var cards: [BankCard] = []
    
    public var owner: Owner = .benificiary
    
    var isLoading = true
    
    public weak var delegate: BankCardsViewControllerDelegate?
    
    public convenience init(owner: Owner) {
        self.init(nibName: "BankCardsViewController", bundle: .init(for: BankCardsViewController.classForCoder()))
        self.owner = owner
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = NSLocalizedString("Bank Cards", comment: "")
        
        tableController.buildTableStructure(reloadData: false)
        
        configureControls()
        
        loadData()
    }
    
    func configureControls() {
        guard let nc = navigationController else { return }
        
        if nc.viewControllers.count == 1 {
            navigationItem.leftBarButtonItem = cancelButton
        }
    }

    func loadData() {
        
        let completion: ([BankCard]?, Error?) -> Void = { [weak self] cards, error in
            self?.isLoading = false
            self?.cards = cards ?? []
            self?.tableController.buildTableStructure(reloadData: true)
            
            if let error = error {
                print(error.localizedDescription)
            }
        }
        
        isLoading = true
        
        self.cards = []
        
        self.tableController.buildTableStructure(reloadData: true)
        
        switch owner {
        case .benificiary:
            P2PCore.beneficiariesCards.cards(complete: completion)
        case .payer:
            P2PCore.payersCards.cards(complete: completion)
        }
    }
    
    func presentLinkCardViewController() {
        let vc = LinkCardViewController(delegate: self)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func dismissViewController() {
        dismiss(animated: true, completion: nil)
    }
}

extension BankCardsViewController: LinkCardViewControllerDelegate {
 
    func linkCardViewControllerComplete(_ vc: LinkCardViewController) {
        navigationController?.popViewController(animated: true)
        loadData()
    }
    
}

class BankCardsTableViewController: TableStructuredController<BankCardsViewController> {
    
    override func configureTableView() {
        super.configureTableView()
        
        let nibs = ["BankCardTableViewCell", "LoadingTableViewCell", "BankCardLinkNewTableViewCell", "BankCardsEmptyTableViewCell"]
        
        for nibName in nibs {
            tableView.register(.init(nibName: nibName, bundle: .init(for: classForCoder)), forCellReuseIdentifier: nibName)
        }
    }
    
    override func buildTableStructure(reloadData: Bool) {
        
        beginBuilding()
        
        var section = newSection()
        
        if vc.isLoading {
            section.append("LoadingTableViewCell")
            append(section: &section)
        } else {
            section.headerTitle = vc.delegate?.bankCardsViewControllerHeaderTitleForBankCardsSection?(vc) ?? NSLocalizedString("Linked Cards", comment: "")
            section.footerTitle = vc.delegate?.bankCardsViewControllerFooterTitleForBankCardsSection?(vc) ?? ""
            if !vc.cards.isEmpty {
                section.append(contentsOf: vc.cards)
            } else {
                section.append("BankCardsEmptyTableViewCell")
            }
            append(section: &section)
        }
        
        if vc.delegate != nil || vc.owner == .benificiary {
            section.headerTitle = vc.delegate?.bankCardsViewControllerHeaderTitleForLinkNewCardSection?(vc) ?? ""
            section.footerTitle = vc.delegate?.bankCardsViewControllerFooterTitleForLinkNewCardSection?(vc) ?? ""
            section.append("BankCardLinkNewTableViewCell")
        }
        
        append(section: &section)
        
        super.buildTableStructure(reloadData: reloadData)
    }
    
    override func tableView(_ tableView: UITableView, reuseIdentifierFor object: Any) -> String? {
        if object is BankCard {
            return "BankCardTableViewCell"
        } else {
            return super.tableView(tableView, reuseIdentifierFor: object)
        }
    }
    
    override func tableView(_ tableView: UITableView, configure cell: UITableViewCell, for object: Any, at indexPath: IndexPath) {
        if let cell = cell as? BankCardTableViewCell, let bankCard = object as? BankCard {
            cell.bankCard = bankCard
        } else if let cell = cell as? BankCardLinkNewTableViewCell {
            switch self.vc.owner {
            case .benificiary:
                cell.titleLabel.text = NSLocalizedString("Link New Card", comment: "")
            case .payer:
                cell.titleLabel.text = NSLocalizedString("Use New Card", comment: "")
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, for object: Any) {
        if let cell = cell as? LoadingTableViewCell {
            cell.startAnimating()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectCellWith identifier: String, object: Any, at indexPath: IndexPath) {
        switch identifier {
        case "BankCardTableViewCell":
            vc.delegate?.bankCardsViewController(vc, didSelect: object as! BankCard)
        case "BankCardLinkNewTableViewCell":
            switch self.vc.owner {
            case .benificiary:
                vc.presentLinkCardViewController()
            case .payer:
                vc.delegate?.bankCardsViewControllerDidSelectLinkNew(vc)
            }
        default:
            break
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowWith object: Any, at indexPath: IndexPath) -> Bool {
        return object is BankCard
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, for object: Any, forRowAt indexPath: IndexPath) {
        guard let card = object as? BankCard else { return }
        let alert = UIAlertController(title: NSLocalizedString("Delete Card", comment: ""), message: NSLocalizedString("Are you really want to delete this card?", comment: ""), preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Delete", comment: ""), style: .destructive, handler: { (_) in
            self.delete(card: card)
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))
        let cell = tableView.cellForRow(at: indexPath)
        alert.popoverPresentationController?.sourceRect = cell?.frame ?? .zero
        alert.popoverPresentationController?.sourceView = cell?.superview
        vc.present(alert, animated: true, completion: nil)
    }
    
    func delete(card: BankCard) {
        let completion: (Error?) -> Void = { [weak self] (error) in
            self?.vc.stopAnimating()
            self?.tableView.isUserInteractionEnabled = true
            if let error = error {
                self?.vc.present(error: error)
            } else {
                self?.deleteRow(with: card)
            }
        }
        
        vc.startAnimating()
        tableView.isUserInteractionEnabled = false
        
        switch vc.owner {
        case .benificiary:
            P2PCore.beneficiariesCards.delete(cardWith: card.cardId, complete: completion)
        case .payer:
            P2PCore.payersCards.delete(cardWith: card.cardId, complete: completion)
        }
    }
    
    func deleteRow(with card: BankCard) {
        guard let row = vc.cards.index(of: card), let indexPath = self.indexPath(for: card), row == indexPath.row else {
            return self.buildTableStructure(reloadData: true)
        }
        vc.cards.remove(at: row)
        self.buildTableStructure(reloadData: false)
        if self.vc.cards.isEmpty {
            self.tableView.reloadRows(at: [indexPath], with: .left)
        } else {
            self.tableView.deleteRows(at: [indexPath], with: .left)
        }
    }
    
}
