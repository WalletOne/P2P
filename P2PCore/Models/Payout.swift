//
//  Payout.swift
//  P2P_iOS
//
//  Created by Vitaliy Kuzmenko on 20/07/2017.
//  Copyright © 2017 Wallet One. All rights reserved.
//

import Foundation

@objc public enum PayoutStateId: Int, RawRepresentable {
    
    case undefined
    
    case paid
    
    public typealias RawValue = String
    
    public var rawValue: RawValue {
        switch self {
        case .paid:
            return "Paid"
        case .undefined:
            return ""
        }
    }
    
    public init?(rawValue: RawValue) {
        switch rawValue {
        case "Paid":
            self = .paid
        default:
            self = .undefined
        }
    }
}

@objc public class Payout: NSObject, Mappable {
    
    public var payoutId: Int = 0
    
    public var payoutStateId: PayoutStateId = .undefined
    
    public var createDate: Date?
    
    public var amount: NSDecimalNumber = 0.0
    
    public var currencyId: CurrencyId = .rub
    
    public var platformDealId: String = ""
    
    public required init(json: [String : Any]) {
        payoutId = map(json["PayoutId"], 0)
        payoutStateId = map(json["PayoutStateId"], .undefined)
        createDate = map(json["CreateDate"])
        amount = map(json["Amount"], 0.0)
        currencyId = map(json["CurrencyId"], .rub)
        platformDealId = map(json["PlatformDealId"], "")
    }
    
}

