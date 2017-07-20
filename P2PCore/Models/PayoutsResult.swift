//
//  PayoutsResult.swift
//  P2P_iOS
//
//  Created by Vitaliy Kuzmenko on 20/07/2017.
//  Copyright © 2017 Wallet One. All rights reserved.
//

import Foundation

@objc public class PayoutsResult: NSObject, Mappable {
    
    public var payouts: [Payout] = []
    
    public var totalCount: Int = 0
    
    public required init(json: [String : Any]) {
        payouts = map(json["Payouts"], [])
        totalCount = map(json["TotalCount"], 0)
    }
    
}

