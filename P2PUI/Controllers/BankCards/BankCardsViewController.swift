//
//  BankCardsTableViewController.swift
//  P2P_iOS
//
//  Created by Vitaliy Kuzmenko on 26/07/2017.
//  Copyright © 2017 Wallet One. All rights reserved.
//

import UIKit
import P2PCore

@objc public class BankCardsViewController: P2PViewController, TableStructuredViewController {
    
    @objc public enum Owner: Int {
        case benificiary, payer
    }
    
    @IBOutlet weak public var tableView: UITableView!
    
    lazy var tableController: BankCardsTableViewController = { return .init(vc: self) }()
    
    public var cards: [BankCard] = []
    
    public var owner: Owner = .benificiary
    
    var isLoading = true
    
    public convenience init(owner: Owner) {
        self.init(nibName: "BankCardsViewController", bundle: kBundle)
        self.owner = owner
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = NSLocalizedString("Bank Cards", comment: "")
        
        tableController.buildTableStructure(reloadData: false)
        
        loadData()
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
        let vc = LinkCardViewController(nibName: "LinkCardViewController", bundle: kBundle)
        vc.delegate = self
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension BankCardsViewController: LinkCardViewControllerDelegate {
 
    func linkCardViewControllerSuccess(_ vc: LinkCardViewController) {
        navigationController?.popViewController(animated: true)
        loadData()
    }
    
}

class BankCardsTableViewController: TableStructuredController<BankCardsViewController> {
    
    override func configureTableView() {
        super.configureTableView()
        
        let nibs = ["BankCardTableViewCell", "LoadingTableViewCell", "BankCardLinkNewTableViewCell"]
        
        for nibName in nibs {
            tableView.register(.init(nibName: nibName, bundle: kBundle), forCellReuseIdentifier: nibName)
        }
    }
    
    override func buildTableStructure(reloadData: Bool) {
        
        beginBuilding()
        
        var section = newSection()
        
        if vc.isLoading {
            section.append("LoadingTableViewCell")
            append(section: &section)
        } else {
            section.headerTitle = NSLocalizedString("Linked Cards", comment: "")
            section.append(contentsOf: vc.cards)
            if !vc.cards.isEmpty {
                append(section: &section)
            }
        }
        
        section.append("BankCardLinkNewTableViewCell")
        
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
            break
        case "BankCardLinkNewTableViewCell":
            vc.presentLinkCardViewController()
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
            self.tableView.deleteSections(IndexSet(integer: indexPath.section), with: .fade)
        } else {
            self.tableView.deleteRows(at: [indexPath], with: .left)
        }
    }
    
}
