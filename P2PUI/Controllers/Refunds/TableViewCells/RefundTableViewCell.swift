//
//  RefundTableViewCell.swift
//  P2P_iOS
//
//  Created by Vitaliy Kuzmenko on 03/08/2017.
//  Copyright © 2017 Wallet One. All rights reserved.
//

import UIKit
import P2PCore

class RefundTableViewCell: UITableViewCell {

    @IBOutlet weak var stateLabel: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var amountLabel: UILabel!
    
    weak var refund: Refund! {
        didSet {
            displayRefund()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func displayRefund() {
        if let date = refund.createDate {
            let df = DateFormatter()
            df.dateStyle = .medium
            df.timeStyle = .short
            dateLabel.text = df.string(from: date)
        } else {
            dateLabel.text = ""
        }
        
        switch refund.refundStateId {
        case RefundStateIdProcessing:
            displayProcessingState()
        case RefundStateIdAccepted:
            displayPaidState()
        case RefundStateIdProcessError:
            displayErrorState()
        default:
            break
        }
        
        let nf = NumberFormatter()
        nf.numberStyle = .currency
        nf.currencyCode = refund.currencyId.alphabeticCode
        nf.currencySymbol = refund.currencyId.symbol
        nf.usesGroupingSeparator = true
        nf.minimumFractionDigits = 0
        nf.maximumFractionDigits = 2
        amountLabel.text = nf.string(from: refund.amount)
    }
    
    func displayProcessingState() {
        stateLabel.text = P2PUILocalizedStrings("Refund Processing...", comment: "")
        amountLabel.textColor = .orange
    }
    
    func displayPaidState() {
        stateLabel.text = P2PUILocalizedStrings("Successful Refund", comment: "")
        amountLabel.textColor = UIColor(red:0.298,  green:0.851,  blue:0.388, alpha:1)
    }
    
    func displayErrorState() {
        stateLabel.text = P2PUILocalizedStrings("Process Error", comment: "")
        amountLabel.textColor = .red
    }
    
}
