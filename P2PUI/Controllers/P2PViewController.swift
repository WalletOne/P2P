//
//  P2PViewController.swift
//  P2P_iOS
//
//  Created by Vitaliy Kuzmenko on 17/07/2017.
//  Copyright © 2017 Wallet One. All rights reserved.
//

import UIKit
import P2PCore


open class P2PViewController: UIViewController {

    let activityView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    
    lazy var activityViewBarButtonItem: UIBarButtonItem = {
        return UIBarButtonItem(customView: self.activityView)
    }()
    
    func startAnimating() {
        navigationItem.rightBarButtonItem = activityViewBarButtonItem
        activityView.startAnimating()
    }
    
    func stopAnimating() {
        navigationItem.rightBarButtonItem = nil
    }
    
}
