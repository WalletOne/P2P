//
//  Deal.swift
//  P2P_iOS
//
//  Created by Vitaliy Kuzmenko on 17/07/2017.
//  Copyright © 2017 Wallet One. All rights reserved.
//

import Foundation

extension String {
    var uppercaseFirst: String {
        let first = String(characters.prefix(1)).capitalized
        let other = String(characters.dropFirst())
        return first + other
    }
}

public let DealStateIdCreated = "Created"
public let DealStateIdPaymentProcessing = "PaymentProcessing"
public let DealStateIdPaymentHold = "PaymentHold"
public let DealStateIdPaymentProcessError = "PaymentProcessError"
public let DealStateIdPaid = "Paid"
public let DealStateIdPayoutProcessing = "PayoutProcessing"
public let DealStateIdPayoutProcessError = "PayoutProcessError"
public let DealStateIdCompleted = "Completed"
public let DealStateIdCanceling = "Canceling"
public let DealStateIdCancelError = "CancelError"
public let DealStateIdCanceled = "Canceled"

public let DealTypeIdDeferred = "Deferred"
public let DealTypeIdInstant = "Instant"

@objc public class Deal: NSObject, Mappable {
    
    public var platformDealId: String = ""
    
    public var dealStateId: String = ""
    
    public var createDate: Date?
    
    public var updatedate: Date?
    
    public var expireDate: Date?
    
    public var amount: NSDecimalNumber = 0.0
    
    public var currencyId: CurrencyId = .rub
    
    public var payerCommissionAmount: NSDecimalNumber = 0.0
    
    public var platformBonusAmount: NSDecimalNumber = 0.0
    
    public var platformPayerId: String = ""
    
    public var payerPaymentToolId: Int = 0
    
    public var payerPhoneNumber: String = ""
    
    public var platformBeneficiaryId: String = ""
    
    public var beneficiaryPaymentToolId: Int = 0
    
    public var shortDescription: String = ""
    
    public var fullDescription: String = ""
    
    public var dealTypeId: String = ""
    
    public required init(json: [String: Any]) {
        platformDealId = map(json["PlatformDealId"], "")
        dealStateId = map(json["DealStateId"], "")
        createDate = map(json["CreateDate"])
        updatedate = map(json["UpdateDate"])
        expireDate = map(json["ExpireDate"])
        amount = map(json["Amount"], 0.0)
        currencyId = map(json["CurrencyId"], .rub)
        payerCommissionAmount = map(json["PayerCommissionAmount"], 0.0)
        platformBonusAmount = map(json["PlatformBonusAmount"], 0.0)
        platformPayerId = map(json["PlatformPayerId"], "")
        payerPhoneNumber = map(json["PayerPhoneNumber"], "")
        payerPaymentToolId = map(json["PayerPaymentToolId"], 0)
        platformBeneficiaryId = map(json["PlatformBeneficiaryId"], "")
        beneficiaryPaymentToolId = map(json["BeneficiaryPaymentToolId"], 0)
        shortDescription = map(json["ShortDescription"], "")
        fullDescription = map(json["FullDescription"], "")
        dealTypeId = map(json["DealTypeId"], "")
    }
    
}
