//
//  PaymentToolTableViewCell.swift
//  P2P_iOS
//
//  Created by Vitaliy Kuzmenko on 26/07/2017.
//  Copyright © 2017 Wallet One. All rights reserved.
//

import UIKit
import P2PCore

extension String {
    
    public var maskEnd: String {
        if self.count <= 4 {
            return self
        }
        var last4digits = String(self.suffix(4))
        last4digits = last4digits.replacingOccurrences(of: "*", with: "•")
        return String(format: "•••• %@", last4digits)
    }
    
}

class PaymentToolTableViewCell: UITableViewCell {

    @IBOutlet weak var typeImageView: UIImageView!
    
    @IBOutlet weak var typeNameLabel: UILabel!
    
    @IBOutlet weak var maskedLabel: UILabel!
    
    weak var paymentTool: PaymentTool! {
        didSet {
            displayPaymentTool()
        }
    }
    
    func displayPaymentTool() {
        typeNameLabel.text = P2PUILocalizedStrings(paymentTool.paymentTypeId, comment: "")

        typeImageView.set(paymentTypeId: paymentTool.paymentTypeId)

        maskedLabel.text = paymentTool.mask.maskEnd
    }
    
}
