//
//  PayDealViewController.swift
//  P2P_iOS
//
//  Created by Vitaliy Kuzmenko on 27/07/2017.
//  Copyright © 2017 Wallet One. All rights reserved.
//

import UIKit
import P2PCore

protocol PayDealViewControllerDelegate: class {
    func payDealViewControllerComplete(_ vc: PayDealViewController)
}

@objc public class PayDealViewController: P2PViewController {

    @IBOutlet weak var webView: UIWebView!
    
    public var dealId: String = ""
    
    public var authData: String?
    
    public var redirectToCardAddition: Bool = false
    
    weak var delegate: PayDealViewControllerDelegate?
    
    public convenience init(dealId: String, redirectToCardAddition: Bool, authData: String? = nil) {
        self.init(nibName: "PayDealViewController", bundle: kBundle)
        self.dealId = dealId
        self.redirectToCardAddition = redirectToCardAddition
        self.authData = authData
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let request = P2PCore.deals.payRequest(dealId: dealId, redirectToCardAddition: redirectToCardAddition, authData: authData)
        
        print(request.httpMethod ?? "" + "=======")
        print(request)
        
        webView.loadRequest(request)
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
        guard let host = url.host else { return true }
        switch host {

        default:
            return true
        }
    }
    
}

