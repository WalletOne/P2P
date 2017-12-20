//
//  LinkPaymentToolViewController.swift
//  P2P_iOS
//
//  Created by Vitaliy Kuzmenko on 27/07/2017.
//  Copyright © 2017 Wallet One. All rights reserved.
//

import UIKit
import P2PCore

public protocol LinkPaymentToolViewControllerDelegate: class {
    func linkPaymentToolViewControllerComplete(_ vc: LinkPaymentToolViewController)
}

open class LinkPaymentToolViewController: P2PViewController {

    @IBOutlet weak var webView: UIWebView!
    
    let returnHost = "p2p-success-link-new-paymenttool"
    
    weak var delegate: LinkPaymentToolViewControllerDelegate?
    
    public convenience init(delegate: LinkPaymentToolViewControllerDelegate) {
        self.init(nibName: "LinkPaymentToolViewController", bundle: .init(for: LinkPaymentToolViewController.classForCoder()))
        self.delegate = delegate
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let request = P2PCore.beneficiariesPaymentTools.addNewPaymentType(returnUrl: "http://" + returnHost, paymentTypeId: nil, redirectToPaymentToolAddition: true)
        
        P2PCore.printDebug(request.httpMethod ?? "" + "=======")
        P2PCore.printDebug(request)
        
        webView.loadRequest(request)
    }

}

extension LinkPaymentToolViewController: UIWebViewDelegate {
    
    open func webViewDidStartLoad(_ webView: UIWebView) {
        startAnimating()
    }
    
    open func webViewDidFinishLoad(_ webView: UIWebView) {
        stopAnimating()
    }
    
    open func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        guard let url = request.url else { return true }
        guard let host = url.host else { return true }
        switch host {
        case returnHost:
            delegate?.linkPaymentToolViewControllerComplete(self)
            return false
        default:
            return true
        }
    }
    
    open func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        
    }
    
}
