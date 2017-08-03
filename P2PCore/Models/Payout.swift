//
//  Payout.swift
//  P2P_iOS
//
//  Created by Vitaliy Kuzmenko on 20/07/2017.
//  Copyright © 2017 Wallet One. All rights reserved.
//

import Foundation

public let PayoutStateIdAccepted = "Accepted"
public let PayoutStateIdProcessing = "Processing"
public let PayoutStateIdProcessError = "ProcessError"

@objc public class Payout: NSObject, Mappable {
    
    public var payoutId: Int = 0
    
    public var payoutStateId: String = ""
    
    public var createDate: Date?
    
    public var amount: NSDecimalNumber = 0.0
    
    public var currencyId: CurrencyId = .rub
    
    public var platformDealId: String = ""
    
    public required init(json: [String : Any]) {
        payoutId = map(json["PayoutId"], 0)
        payoutStateId = map(json["PayoutStateId"], "")
        createDate = map(json["CreateDate"])
        amount = map(json["Amount"], 0.0)
        currencyId = map(json["CurrencyId"], .rub)
        platformDealId = map(json["PlatformDealId"], "")
    }
    
}

