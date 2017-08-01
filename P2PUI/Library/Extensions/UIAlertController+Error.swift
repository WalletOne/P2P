//
//  UIAlertController+Error.swift
//  P2P_iOS
//
//  Created by Vitaliy Kuzmenko on 31/07/2017.
//  Copyright © 2017 Wallet One. All rights reserved.
//

import UIKit

extension UIAlertController {
    
    convenience init(error: Error) {
        self.init(title: NSLocalizedString("Error", comment: ""), message: error.localizedDescription, preferredStyle: .alert)
        addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))
    }
    
}

extension UIViewController {
    
    public func present(error: Error) {
        let alert = UIAlertController(error: error)
        self.present(alert, animated: true, completion: nil)
    }
    
}

