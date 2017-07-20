//
//  Refund.swift
//  P2P_iOS
//
//  Created by Vitaliy Kuzmenko on 20/07/2017.
//  Copyright © 2017 Wallet One. All rights reserved.
//

import Foundation

@objc public enum RefundStateId: Int, RawRepresentable {
    
    case undefined
    
    case accepted
    
    public typealias RawValue = String
    
    public var rawValue: RawValue {
        switch self {
        case .accepted:
            return "Accepted"
        case .undefined:
            return ""
        }
    }
    
    public init?(rawValue: RawValue) {
        switch rawValue {
        case "Accepted":
            self = .accepted
        default:
            self = .undefined
        }
    }
}

@objc public class Refund: NSObject, Mappable {
    
    public var refundId: Int = 0
    
    public var refundStateId: RefundStateId = .undefined
    
    public var createDate: Date?
    
    public var amount: NSDecimalNumber = 0.0
    
    public var currencyId: CurrencyId = .rub
    
    public var platformDealId: String = ""
    
    public required init(json: [String : Any]) {
        refundId = map(json["RefundId"], 0)
        refundStateId = map(json["RefundStateId"], .undefined)
        createDate = map(json["CreateDate"])
        amount = map(json["Amount"], 0.0)
        currencyId = map(json["CurrencyId"], .rub)
        platformDealId = map(json["PlatformDealId"], "")
    }
    
}
