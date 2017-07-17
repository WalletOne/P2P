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

@objc public class Deal: NSObject {
    
    public var platformDealId: String = ""
    
    public var dealStateId: DealStateId = .undefined
    
    public var createDate: Date?
    
    public var updatedate: Date?
    
    public var expireDate: Date?
    
    public var amount: NSDecimalNumber = 0.0
    
    public var currencyId: CurrencyId = .rub
    
    public var platformPayerId: String = ""
    
    public var payerCardId: String = ""
    
    public var platformBeneficiaryId: String = ""
    
    public var beneficiaryCardId: String = ""
    
    public var shortDescription: String = ""
    
    public var fullDescription: String = ""
    
    public var dealTypeId: DealTypeId = .undefined
    
    
    
}
