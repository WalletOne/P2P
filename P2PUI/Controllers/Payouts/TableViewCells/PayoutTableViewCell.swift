//
//  PayoutTableViewCell.swift
//  P2P_iOS
//
//  Created by Vitaliy Kuzmenko on 03/08/2017.
//  Copyright © 2017 Wallet One. All rights reserved.
//

import UIKit
import P2PCore

class PayoutTableViewCell: UITableViewCell {

    @IBOutlet weak var stateLabel: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var amountLabel: UILabel!
    
    weak var payout: Payout! {
        didSet {
            displayPayout()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func displayPayout() {
        if let date = payout.createDate {
            let df = DateFormatter()
            df.dateStyle = .medium
            df.timeStyle = .short
            dateLabel.text = df.string(from: date)
        } else {
            dateLabel.text = ""
        }
        
        switch payout.payoutStateId {
        case PayoutStateIdProcessing:
            displayProcessingState()
        case PayoutStateIdAccepted:
            displayAcceptedState()
        case PayoutStateIdProcessError:
            displayErrorState()
        default:
            break
        }
        
        let nf = NumberFormatter()
        nf.numberStyle = .currency
        nf.currencyCode = payout.currencyId.alphabeticCode
        nf.currencySymbol = payout.currencyId.symbol
        nf.usesGroupingSeparator = true
        nf.minimumFractionDigits = 0
        nf.maximumFractionDigits = 2
        amountLabel.text = nf.string(from: payout.amount)
    }
    
    func displayProcessingState() {
        stateLabel.text = NSLocalizedString("Payout Processing...", comment: "")
        amountLabel.textColor = .orange
    }
    
    func displayAcceptedState() {
        stateLabel.text = NSLocalizedString("Successful Payout", comment: "")
        amountLabel.textColor = UIColor(red:0.298,  green:0.851,  blue:0.388, alpha:1)
    }
    
    func displayErrorState() {
        stateLabel.text = NSLocalizedString("Process Error", comment: "")
        amountLabel.textColor = .red
    }
    
}
