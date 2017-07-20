//
//  Deal.swift
//  P2P_iOS
//
//  Created by Vitaliy Kuzmenko on 17/07/2017.
//  Copyright © 2017 Wallet One. All rights reserved.
//

import Foundation

@objc public enum DealStateId: Int, RawRepresentable {
    
    case undefined
    
    case created
    
    public typealias RawValue = String
    
    public var rawValue: RawValue {
        switch self {
        case .created:
            return "Created"
        case .undefined:
            return ""
        }
    }
    
    public init?(rawValue: RawValue) {
        switch rawValue {
            case "Created":
            self = .created
        default:
            self = .undefined
        }
    }
}

@objc public enum DealTypeId: Int, RawRepresentable {
    
    case undefined
    
    case deferred
    
    public typealias RawValue = String
    
    public var rawValue: RawValue {
        switch self {
        case .deferred:
            return "Deferred"
        case .undefined:
            return ""
        }
    }
    
    public init?(rawValue: RawValue) {
        switch rawValue {
        case "Deferred":
            self = .deferred
        default:
            self = .undefined
        }
    }
}

@objc public class Deal: NSObject, Mappable {
    
    public var platformDealId: String = ""
    
    public var dealStateId: DealStateId = .undefined
    
    public var createDate: Date?
    
    public var updatedate: Date?
    
    public var expireDate: Date?
    
    public var amount: NSDecimalNumber = 0.0
    
    public var currencyId: CurrencyId = .rub
    
    public var platformPayerId: String = ""
    
    public var payerCardId: Int = 0
    
    public var platformBeneficiaryId: String = ""
    
    public var beneficiaryCardId: Int = 0
    
    public var shortDescription: String = ""
    
    public var fullDescription: String = ""
    
    public var dealTypeId: DealTypeId = .undefined
    
    public required init(json: [String: Any]) {
        platformDealId = map(json["PlatformDealId"], "")
        dealTypeId = map(json["DealStateId"], .undefined)
        createDate = map(json["CreateDate"])
        updatedate = map(json["UpdateDate"])
        expireDate = map(json["ExpireDate"])
        amount = map(json["Amount"], 0.0)
        currencyId = map(json["CurrencyId"], .rub)
        platformPayerId = map(json["PlatformPayerId"], "")
        payerCardId = map(json["PayerCardId"], 0)
        platformBeneficiaryId = map(json["PlatformBeneficiaryId"], "")
        beneficiaryCardId = map(json["BeneficiaryCardId"], 0)
        shortDescription = map(json["ShortDescription"], "")
        fullDescription = map(json["FullDescription"], "")
        dealTypeId = map(json["DealTypeId"], .undefined)
    }
    
}
