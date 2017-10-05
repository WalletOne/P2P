//
//  PayDealViewController.swift
//  P2P_iOS
//
//  Created by Vitaliy Kuzmenko on 27/07/2017.
//  Copyright © 2017 Wallet One. All rights reserved.
//

import UIKit
import P2PCore

@objc public protocol PayDealViewControllerDelegate: NSObjectProtocol {
    func payDealViewControllerComplete(_ vc: PayDealViewController)
}

@objc public class PayDealViewController: P2PViewController {

    @IBOutlet weak var webView: UIWebView!
    
    public var dealId: String = ""
    
    public var authData: String?
    
    public var redirectToCardAddition: Bool = false
    
    let returnHost = "p2p-success-pay-deal"
    
    public weak var delegate: PayDealViewControllerDelegate?
    
    lazy var cancelButton: UIBarButtonItem = {
        return UIBarButtonItem(title: P2PUILocalizedStrings("Cancel", comment: ""), style: .done, target: self, action: #selector(dismissViewController))
    }()
    
    public convenience init(dealId: String, redirectToCardAddition: Bool, authData: String? = nil) {
        self.init(nibName: "PayDealViewController", bundle: .init(for: PayDealViewController.classForCoder()))
        self.dealId = dealId
        self.redirectToCardAddition = redirectToCardAddition
        self.authData = authData
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let request = P2PCore.deals.payRequest(dealId: dealId, redirectToCardAddition: redirectToCardAddition, authData: authData, returnUrl: "http://" + returnHost)
        
        P2PCore.printDebug(request.httpMethod ?? "" + "=======")
        P2PCore.printDebug(request)
        
        webView.loadRequest(request)
        
        configureControls()
    }
    
    func configureControls() {
        guard let nc = navigationController else { return }
        
        if nc.viewControllers.count == 1 {
            navigationItem.leftBarButtonItem = cancelButton
        }
    }
    
    @objc func dismissViewController() {
        dismiss(animated: true, completion: nil)
    }

}

extension PayDealViewController: UIWebViewDelegate {
    
    public func webViewDidStartLoad(_ webView: UIWebView) {
        startAnimating()
    }
    
    public func webViewDidFinishLoad(_ webView: UIWebView) {
        stopAnimating()
    }
    
    public func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        guard let url = request.url else { return true }
        
        P2PCore.printDebug(url)
        
        guard let host = url.host else { return true }
        switch host {
        case returnHost:
            delegate?.payDealViewControllerComplete(self)
            return false
        default:
            return true
        }
    }
    
}

