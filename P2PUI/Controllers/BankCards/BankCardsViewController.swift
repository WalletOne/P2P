//
//  BankCardsTableViewController.swift
//  P2P_iOS
//
//  Created by Vitaliy Kuzmenko on 26/07/2017.
//  Copyright © 2017 Wallet One. All rights reserved.
//

import UIKit
import P2PCore

class BankCardsViewController: UIViewController, TableStructuredViewController {
    
    enum Owner {
        case benificiar, payer
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    lazy var tableController: BankCardsTableViewController = { return .init(vc: self) }()
    
    var cards: [BankCard] = []
    
    var owner: Owner = .benificiar
    
    var ownerId: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadData()
    }

    func loadData() {
        
        let completion: ([BankCard]?, Error?) -> Void = { cards, error in
            self.cards = cards ?? []
            //self.
        }
        
        switch owner {
        case .benificiar:
            P2PCore.beneficiariesCards.cards(of: ownerId, complete: completion)
        case .payer:
            P2PCore.payersCards.cards(of: ownerId, complete: completion)
        }
    }
    
}

class BankCardsTableViewController: TableStructuredController<BankCardsViewController> {
    
    override func configureTableView() {
        super.configureTableView()
        
        let nibs = ["BankCardTableViewCell"]
        
        for nibName in nibs {
            tableView.register(.init(nibName: nibName, bundle: kBundle), forCellReuseIdentifier: nibName)
        }
    }
    
    override func buildTableStructure(reloadData: Bool) {
        
        beginBuilding()
        
        var section = newSection()
        
        section.append(contentsOf: vc.cards)
        
        append(section: &section)
        
        super.buildTableStructure(reloadData: true)
    }
    
}
