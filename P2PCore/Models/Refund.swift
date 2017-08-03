//
//  Refund.swift
//  P2P_iOS
//
//  Created by Vitaliy Kuzmenko on 20/07/2017.
//  Copyright © 2017 Wallet One. All rights reserved.
//

import Foundation

public let RefundStateIdAccepted = "Accepted"
public let RefundStateIdProcessing = "Processing"
public let RefundStateIdProcessError = "ProcessError"

@objc public class Refund: NSObject, Mappable {
    
    public var refundId: Int = 0
    
    public var refundStateId: String = ""
    
    public var createDate: Date?
    
    public var amount: NSDecimalNumber = 0.0
    
    public var currencyId: CurrencyId = .rub
    
    public var platformDealId: String = ""
    
    public required init(json: [String : Any]) {
        refundId = map(json["RefundId"], 0)
        refundStateId = map(json["RefundStateId"], "")
        createDate = map(json["CreateDate"])
        amount = map(json["Amount"], 0.0)
        currencyId = map(json["CurrencyId"], .rub)
        platformDealId = map(json["PlatformDealId"], "")
    }
    
}
