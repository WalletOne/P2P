//
//  BankCardTableViewCell.swift
//  P2P_iOS
//
//  Created by Vitaliy Kuzmenko on 26/07/2017.
//  Copyright © 2017 Wallet One. All rights reserved.
//

import UIKit
import P2PCore

extension String {
    
    public var maskEnd: String {
        if characters.count <= 4 {
            return self
        }
        let last4digitsIndex = characters.index(endIndex, offsetBy: -4)
        let last4digits = self.substring(from: last4digitsIndex)
        return String(format: "•••• %@", last4digits)
    }
    
}

class BankCardTableViewCell: UITableViewCell {

    @IBOutlet weak var typeImageView: UIImageView!
    
    @IBOutlet weak var typeNameLabel: UILabel!
    
    @IBOutlet weak var maskedLabel: UILabel!
    
    weak var bankCard: BankCard! {
        didSet {
            displayBankCard()
        }
    }
    
    func displayBankCard() {
        let v = CreditCardValidator()
        
        if let type = v.type(from: bankCard.cardMask) {
            typeNameLabel.text = type.name
            typeImageView.image = UIImage(named: type.name + "Mini", in: kBundle, compatibleWith: nil)
        } else {
            typeNameLabel.text = NSLocalizedString("Unknown Card Type", comment: "")
            typeImageView.image = nil
        }
        
        maskedLabel.text = bankCard.cardMask.maskEnd
    }
    
}
