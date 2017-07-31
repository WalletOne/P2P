//
//  Request.swift
//  P2P_iOS
//
//  Created by Vitaliy Kuzmenko on 31/07/2017.
//  Copyright © 2017 Wallet One. All rights reserved.
//

import Foundation

func ==(l: DealRequest, r: DealRequest) -> Bool {
    return l.deal == r.deal && l.freelancer == r.freelancer
}

class DealRequest: Equatable {
    
    var deal: Deal
    
    var freelancer: Freelancer
    
    var amount: NSDecimalNumber = 0.0
    
    init(deal: Deal, freelancer: Freelancer, amount: NSDecimalNumber) {
        self.deal = deal
        self.freelancer = freelancer
        self.amount = amount
    }
    
}
