//
//  LinkCardViewController.swift
//  P2P_iOS
//
//  Created by Vitaliy Kuzmenko on 27/07/2017.
//  Copyright © 2017 Wallet One. All rights reserved.
//

import UIKit
import P2PCore

protocol LinkCardViewControllerDelegate: class {
    func linkCardViewControllerComplete(_ vc: LinkCardViewController)
}

class LinkCardViewController: P2PViewController {

    @IBOutlet weak var webView: UIWebView!
    
    let returnHost = "p2p-success-link-new-card"
    
    weak var delegate: LinkCardViewControllerDelegate?
    
    public convenience init(delegate: LinkCardViewControllerDelegate) {
        self.init(nibName: "LinkCardViewController", bundle: kBundle)
        self.delegate = delegate
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let request = P2PCore.beneficiariesCards.linkNewCardRequest(returnUrl: "http://" + returnHost)
        
        print(request.httpMethod ?? "" + "=======")
        print(request)
        
        webView.loadRequest(request)
    }

}

extension LinkCardViewController: UIWebViewDelegate {
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        startAnimating()
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        stopAnimating()
    }
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        guard let url = request.url else { return true }
        guard let host = url.host else { return true }
        switch host {
        case returnHost:
            delegate?.linkCardViewControllerComplete(self)
            return false
        default:
            return true
        }
    }
    
}

