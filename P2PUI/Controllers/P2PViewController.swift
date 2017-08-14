//
//  P2PViewController.swift
//  P2P_iOS
//
//  Created by Vitaliy Kuzmenko on 17/07/2017.
//  Copyright © 2017 Wallet One. All rights reserved.
//

import UIKit
import P2PCore

private func localizationsBundle() -> Bundle {
    let assetPath = Bundle(for: P2PViewController.self).resourcePath!
    return Bundle(path: NSString(string: assetPath).appendingPathComponent("Localizations.bundle"))!
}

func P2PUILocalizedStrings(_ string: String, comment: String) -> String {
    return NSLocalizedString(string, tableName: "P2PUI", bundle: localizationsBundle(), value: "", comment: comment)
}

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
