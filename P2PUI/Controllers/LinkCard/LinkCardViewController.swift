//
//  LinkCardViewController.swift
//  P2P_iOS
//
//  Created by Vitaliy Kuzmenko on 27/07/2017.
//  Copyright © 2017 Wallet One. All rights reserved.
//

import UIKit
import P2PCore

class LinkCardViewController: UIViewController {

    @IBOutlet weak var webView: UIWebView!
    
    var owner: BankCardsViewController.Owner = .benificiary
    
    public convenience init(owner: BankCardsViewController.Owner) {
        self.init(nibName: "LinkCardViewController", bundle: kBundle)
        self.owner = owner
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let request = P2PCore.beneficiariesCards.linkNewCardRequest(returnUrl: "http://p2p_success_link_new_card")
        webView.loadRequest(request)
    }

}

extension LinkCardViewController: UIWebViewDelegate {
    
    
    
}

