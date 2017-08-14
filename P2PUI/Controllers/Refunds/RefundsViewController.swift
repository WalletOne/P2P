//
//  RefundsViewController.swift
//  P2P_iOS
//
//  Created by Vitaliy Kuzmenko on 03/08/2017.
//  Copyright © 2017 Wallet One. All rights reserved.
//

import UIKit
import P2PCore

@objc open class RefundsViewController: UIViewController, TableStructuredViewController {
    
    @IBOutlet weak open var tableView: UITableView!
    
    open var refunds: [Refund] = []
    
    open var dealId: String?
    
    lazy var tableController: RefundsTableController = { return .init(vc: self) }()
    
    var isLoading = false
    
    var isLoadMoreInProgress = false
    
    var isAllowLoadMore = false
    
    var pageNumber: Int = 0
    
    var itemsPerPage: Int = 10
    
    convenience public init(dealId: String?) {
        self.init(nibName: "RefundsViewController", bundle: .init(for: RefundsViewController.classForCoder()))
        self.dealId = dealId
    }

    override open func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = P2PUILocalizedStrings("Refunds", comment: "")

        // Do any additional setup after loading the view.
        loadData()
    }

    func loadData() {
        
        isLoading = true
        
        tableController.buildTableStructure(reloadData: true)
        
        self.pageNumber = 1
        
        P2PCore.refunds.refunds(pageNumber: pageNumber, itemsPerPage: itemsPerPage, dealId: dealId) { (result, error) in
            let refunds = result?.refunds ?? []
            self.isLoading = false
            self.pageNumber += 1
            self.refunds = refunds
            self.isAllowLoadMore = !refunds.isEmpty
            self.tableController.buildTableStructure(reloadData: true)
        }
    }
    
    func loadMore() {
        
        isLoadMoreInProgress = true
        
        P2PCore.refunds.refunds(pageNumber: pageNumber, itemsPerPage: itemsPerPage, dealId: dealId) { (result, error) in
            self.isLoadMoreInProgress = false
            let refunds = result?.refunds ?? []
            self.refunds.append(contentsOf: refunds)
            self.pageNumber += 1
            self.isAllowLoadMore = !refunds.isEmpty
            self.tableController.buildTableStructure(reloadData: true)
        }
    }
    
}

class RefundsTableController: TableStructuredController<RefundsViewController> {
    
    override func configureTableView() {
        super.configureTableView()
        
        let nibs = ["RefundTableViewCell", "LoadingTableViewCell", "RefundsEmptyTableViewCell"]
        
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
            if vc.refunds.isEmpty {
                section.append("RefundsEmptyTableViewCell")
            } else {
                section.append(contentsOf: vc.refunds)
                
                if vc.isAllowLoadMore {
                    section.append("LoadingTableViewCell")
                }
            }
        }
        
        append(section: &section)
        
        super.buildTableStructure(reloadData: reloadData)
    }
    
    override func tableView(_ tableView: UITableView, reuseIdentifierFor object: Any) -> String? {
        if object is Refund {
            return "RefundTableViewCell"
        } else {
            return super.tableView(tableView, reuseIdentifierFor: object)
        }
    }
    
    override func tableView(_ tableView: UITableView, configure cell: UITableViewCell, for object: Any, at indexPath: IndexPath) {
        if let cell = cell as? RefundTableViewCell, let refund = object as? Refund {
            cell.refund = refund
            
            if vc.isAllowLoadMore && !vc.isLoadMoreInProgress {
                vc.loadMore()
            }
        } else if let cell = cell as? RefundsEmptyTableViewCell {
            cell.textLabel?.text = P2PUILocalizedStrings("No Refunds", comment: "")
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, for object: Any) {
        if let cell = cell as? LoadingTableViewCell {
            cell.startAnimating()
        }
    }
    
}
