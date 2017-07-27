//
//  BankCardsTableViewController.swift
//  P2P_iOS
//
//  Created by Vitaliy Kuzmenko on 26/07/2017.
//  Copyright © 2017 Wallet One. All rights reserved.
//

import UIKit
import P2PCore

@objc public class BankCardsViewController: UIViewController, TableStructuredViewController {
    
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
        
        tableController.buildTableStructure(reloadData: false)
        
        loadData()
    }

    func loadData() {
        
        let completion: ([BankCard]?, Error?) -> Void = { cards, error in
            self.isLoading = false
            self.cards = cards ?? []
            self.tableController.buildTableStructure(reloadData: false)
            
            if let error = error {
                print(error.localizedDescription)
            }
        }
        
        isLoading = true
        
        switch owner {
        case .benificiary:
            P2PCore.beneficiariesCards.cards(complete: completion)
        case .payer:
            P2PCore.payersCards.cards(complete: completion)
        }
    }
    
    func presentLinkCardViewController() {
        let vc = LinkCardViewController(nibName: "LinkCardViewController", bundle: kBundle)
        navigationController?.pushViewController(vc, animated: true)
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
            section.append(contentsOf: vc.cards)
            if !vc.cards.isEmpty {
                append(section: &section)
            }
        }
        
        section.append("BankCardLinkNewTableViewCell")
        
        append(section: &section)
        
        super.buildTableStructure(reloadData: true)
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
    
    
    
}
