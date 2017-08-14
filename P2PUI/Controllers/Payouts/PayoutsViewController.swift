//
//  PayoutsViewController.swift
//  P2P_iOS
//
//  Created by Vitaliy Kuzmenko on 03/08/2017.
//  Copyright © 2017 Wallet One. All rights reserved.
//

import UIKit
import P2PCore

@objc open class PayoutsViewController: UIViewController, TableStructuredViewController {
    
    @IBOutlet weak open var tableView: UITableView!
    
    open var payouts: [Payout] = []
    
    open var dealId: String?
    
    lazy var tableController: PayoutsTableController = { return .init(vc: self) }()
    
    var isLoading = false
    
    var isLoadMoreInProgress = false
    
    var isAllowLoadMore = false
    
    var pageNumber: Int = 0
    
    var itemsPerPage: Int = 10
    
    convenience public init(dealId: String?) {
        self.init(nibName: "PayoutsViewController", bundle: .init(for: PayoutsViewController.classForCoder()))
        self.dealId = dealId
    }

    override open func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = P2PUILocalizedStrings("Payouts", comment: "")

        // Do any additional setup after loading the view.
        loadData()
    }

    func loadData() {
        
        isLoading = true
        
        tableController.buildTableStructure(reloadData: true)
        
        self.pageNumber = 1
        
        P2PCore.payouts.payouts(pageNumber: pageNumber, itemsPerPage: itemsPerPage, dealId: dealId) { (result, error) in
            let payouts = result?.payouts ?? []
            self.isLoading = false
            self.pageNumber += 1
            self.payouts = payouts
            self.isAllowLoadMore = !payouts.isEmpty
            self.tableController.buildTableStructure(reloadData: true)
        }
    }
    
    func loadMore() {
        
        isLoadMoreInProgress = true
        
        P2PCore.payouts.payouts(pageNumber: pageNumber, itemsPerPage: itemsPerPage, dealId: dealId) { (result, error) in
            self.isLoadMoreInProgress = false
            let payouts = result?.payouts ?? []
            self.payouts.append(contentsOf: payouts)
            self.pageNumber += 1
            self.isAllowLoadMore = !payouts.isEmpty
            self.tableController.buildTableStructure(reloadData: true)
        }
    }
    
}

class PayoutsTableController: TableStructuredController<PayoutsViewController> {
    
    override func configureTableView() {
        super.configureTableView()
        
        let nibs = ["PayoutTableViewCell", "LoadingTableViewCell", "PayoutsEmptyTableViewCell"]
        
        for nibName in nibs {
            tableView.register(.init(nibName: nibName, bundle: .init(for: classForCoder)), forCellReuseIdentifier: nibName)
        }
    }
    
    override func buildTableStructure(reloadData: Bool) {
        
        beginBuilding()
        
        var section = newSection()
        
        if vc.isLoading {
            section.append("LoadingTableViewCell")
        } else {
            if vc.payouts.isEmpty {
                section.append("PayoutsEmptyTableViewCell")
            } else {
                section.append(contentsOf: vc.payouts)
                
                if vc.isAllowLoadMore {
                    section.append("LoadingTableViewCell")
                }
            }
        }
        
        append(section: &section)
        
        super.buildTableStructure(reloadData: reloadData)
    }
    
    override func tableView(_ tableView: UITableView, reuseIdentifierFor object: Any) -> String? {
        if object is Payout {
            return "PayoutTableViewCell"
        } else {
            return super.tableView(tableView, reuseIdentifierFor: object)
        }
    }
    
    override func tableView(_ tableView: UITableView, configure cell: UITableViewCell, for object: Any, at indexPath: IndexPath) {
        if let cell = cell as? PayoutTableViewCell, let payout = object as? Payout {
            cell.payout = payout
            
            if vc.isAllowLoadMore && !vc.isLoadMoreInProgress {
                vc.loadMore()
            }
        } else if let cell = cell as? PayoutsEmptyTableViewCell {
            cell.textLabel?.text = P2PUILocalizedStrings("No Payouts", comment: "")
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, for object: Any) {
        if let cell = cell as? LoadingTableViewCell {
            cell.startAnimating()
        }
    }
    
}
