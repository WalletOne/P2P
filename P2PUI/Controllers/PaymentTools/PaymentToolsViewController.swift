//
//  PaymentToolsTableViewController.swift
//  P2P_iOS
//
//  Created by Vitaliy Kuzmenko on 26/07/2017.
//  Copyright © 2017 Wallet One. All rights reserved.
//

import UIKit
import P2PCore

@objc public protocol PaymentToolsViewControllerDelegate: NSObjectProtocol {
    @objc optional func paymentToolsViewControllerHeaderTitleForPaymentToolsSection(_ vc: PaymentToolsViewController) -> String
    @objc optional func paymentToolsViewControllerFooterTitleForPaymentToolsSection(_ vc: PaymentToolsViewController) -> String
    
    @objc optional func paymentToolsViewControllerHeaderTitleForLinkNewPaymentToolSection(_ vc: PaymentToolsViewController) -> String
    @objc optional func paymentToolsViewControllerFooterTitleForLinkNewPaymentToolSection(_ vc: PaymentToolsViewController) -> String
    
    func paymentToolsViewController(_ vc: PaymentToolsViewController, didSelect paymentTool: PaymentTool)
    
    // Called only when owner is .payer
    func paymentToolsViewControllerDidSelectLinkNew(_ vc: PaymentToolsViewController)
}

@objc open class PaymentToolsViewController: P2PViewController, TableStructuredViewController {
    
    @objc public enum Owner: Int {
        case benificiary, payer
    }
    
    @IBOutlet weak open var tableView: UITableView!
    
    lazy var cancelButton: UIBarButtonItem = {
        return UIBarButtonItem(title: P2PUILocalizedStrings("Cancel", comment: ""), style: .done, target: self, action: #selector(dismissViewController))
    }()
    
    lazy var tableController: PaymentToolsTableViewController = { return .init(vc: self) }()
    
    public var paymentTools: [PaymentTool] = []
    
    public var owner: Owner = .benificiary
    
    var isLoading = true
    
    public weak var delegate: PaymentToolsViewControllerDelegate?
    
    public convenience init(owner: Owner, delegate: PaymentToolsViewControllerDelegate?) {
        self.init(nibName: "PaymentToolsViewController", bundle: .init(for: PaymentToolsViewController.classForCoder()))
        self.owner = owner
        self.delegate = delegate
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = P2PUILocalizedStrings("Payment Tools", comment: "")
        
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
        
        let completion: (PaymentToolsResult?, Error?) -> Void = { [weak self] paymentTools, error in
            self?.isLoading = false
            self?.paymentTools = paymentTools?.paymentTools ?? []
            self?.tableController.buildTableStructure(reloadData: true)
            
            if let error = error {
                P2PCore.printDebug(error.localizedDescription)
            }
        }
        
        isLoading = true
        
        self.paymentTools = []
        
        self.tableController.buildTableStructure(reloadData: true)
        
        switch owner {
        case .benificiary:
            P2PCore.beneficiariesPaymentTools.paymentTools(complete: completion)
        case .payer:
            P2PCore.payersPaymentTools.paymentTools(complete: completion)
        }
    }
    
    func presentLinkPaymentToolViewController() {
        let vc = LinkPaymentToolViewController(delegate: self)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func dismissViewController() {
        dismiss(animated: true, completion: nil)
    }
}

extension PaymentToolsViewController: LinkPaymentToolViewControllerDelegate {
 
    open func linkPaymentToolViewControllerComplete(_ vc: LinkPaymentToolViewController) {
        navigationController?.popViewController(animated: true)
        loadData()
    }
    
}

class PaymentToolsTableViewController: TableStructuredController<PaymentToolsViewController> {
    
    override func configureTableView() {
        super.configureTableView()
        
        let nibs = ["PaymentToolTableViewCell", "LoadingTableViewCell", "PaymentToolLinkNewTableViewCell", "PaymentToolsEmptyTableViewCell"]
        
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
            section.headerTitle = vc.delegate?.paymentToolsViewControllerHeaderTitleForPaymentToolsSection?(vc) ?? P2PUILocalizedStrings("Linked Payment Tools", comment: "")
            section.footerTitle = vc.delegate?.paymentToolsViewControllerFooterTitleForPaymentToolsSection?(vc) ?? ""
            if !vc.paymentTools.isEmpty {
                section.append(contentsOf: vc.paymentTools)
            } else {
                section.append("PaymentToolsEmptyTableViewCell")
            }
            append(section: &section)
        }
        
        if vc.delegate != nil || vc.owner == .benificiary {
            section.headerTitle = vc.delegate?.paymentToolsViewControllerHeaderTitleForLinkNewPaymentToolSection?(vc) ?? ""
            section.footerTitle = vc.delegate?.paymentToolsViewControllerFooterTitleForLinkNewPaymentToolSection?(vc) ?? ""
            section.append("PaymentToolLinkNewTableViewCell")
        }
        
        append(section: &section)
        
        super.buildTableStructure(reloadData: reloadData)
    }
    
    override func tableView(_ tableView: UITableView, reuseIdentifierFor object: Any) -> String? {
        if object is PaymentTool {
            return "PaymentToolTableViewCell"
        } else {
            return super.tableView(tableView, reuseIdentifierFor: object)
        }
    }
    
    override func tableView(_ tableView: UITableView, configure cell: UITableViewCell, for object: Any, at indexPath: IndexPath) {
        if let cell = cell as? PaymentToolTableViewCell, let paymentTool = object as? PaymentTool {
            cell.paymentTool = paymentTool
        } else if let cell = cell as? PaymentToolLinkNewTableViewCell {
            switch self.vc.owner {
            case .benificiary:
                cell.titleLabel.text = P2PUILocalizedStrings("Link New Payment Tool", comment: "")
            case .payer:
                cell.titleLabel.text = P2PUILocalizedStrings("Use New Payment Tool", comment: "")
            }
        } else if let cell = cell as? PaymentToolsEmptyTableViewCell {
            cell.textLabel?.text = P2PUILocalizedStrings("No Linekd Payment Tools", comment: "")
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, for object: Any) {
        if let cell = cell as? LoadingTableViewCell {
            cell.startAnimating()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectCellWith identifier: String, object: Any, at indexPath: IndexPath) {
        switch identifier {
        case "PaymentToolTableViewCell":
            vc.delegate?.paymentToolsViewController(vc, didSelect: object as! PaymentTool)
        case "PaymentToolLinkNewTableViewCell":
            switch self.vc.owner {
            case .benificiary:
                vc.presentLinkPaymentToolViewController()
            case .payer:
                vc.delegate?.paymentToolsViewControllerDidSelectLinkNew(vc)
            }
        default:
            break
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowWith object: Any, at indexPath: IndexPath) -> Bool {
        return object is PaymentTool
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, for object: Any, forRowAt indexPath: IndexPath) {
        guard let paymentTool = object as? PaymentTool else { return }
        let alert = UIAlertController(title: P2PUILocalizedStrings("Delete Payment Tool", comment: ""), message: P2PUILocalizedStrings("Are you really want to delete this payment tool?", comment: ""), preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: P2PUILocalizedStrings("Delete", comment: ""), style: .destructive, handler: { (_) in
            self.delete(paymentTool: paymentTool)
        }))
        alert.addAction(UIAlertAction(title: P2PUILocalizedStrings("Cancel", comment: ""), style: .cancel, handler: nil))
        let cell = tableView.cellForRow(at: indexPath)
        alert.popoverPresentationController?.sourceRect = cell?.frame ?? .zero
        alert.popoverPresentationController?.sourceView = cell?.superview
        vc.present(alert, animated: true, completion: nil)
    }
    
    func delete(paymentTool: PaymentTool) {
        let completion: (Error?) -> Void = { [weak self] (error) in
            self?.vc.stopAnimating()
            self?.tableView.isUserInteractionEnabled = true
            if let error = error {
                self?.vc.present(error: error)
            } else {
                self?.deleteRow(with: paymentTool)
            }
        }
        
        vc.startAnimating()
        tableView.isUserInteractionEnabled = false
        
        switch vc.owner {
        case .benificiary:
            P2PCore.beneficiariesPaymentTools.delete(paymentToolWith: paymentTool.paymentToolId, complete: completion)
        case .payer:
            P2PCore.payersPaymentTools.delete(paymentToolWith: paymentTool.paymentToolId, complete: completion)
        }
    }
    
    func deleteRow(with paymentTool: PaymentTool) {
        guard let row = vc.paymentTools.index(of: paymentTool), let indexPath = self.indexPath(for: paymentTool), row == indexPath.row else {
            return self.buildTableStructure(reloadData: true)
        }
        vc.paymentTools.remove(at: row)
        self.buildTableStructure(reloadData: false)
        if self.vc.paymentTools.isEmpty {
            self.tableView.reloadRows(at: [indexPath], with: .left)
        } else {
            self.tableView.deleteRows(at: [indexPath], with: .left)
        }
    }
    
}
