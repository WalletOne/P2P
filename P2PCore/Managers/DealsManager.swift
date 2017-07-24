//
//  DealsManager.swift
//  P2P_iOS
//
//  Created by Vitaliy Kuzmenko on 17/07/2017.
//  Copyright © 2017 Wallet One. All rights reserved.
//

import Foundation

extension URLComposer {
 
    func deals() -> String {
        return relativeToBase("deals")
    }
    
    func deals(platformDealId: String) -> String {
        return relative(deals(), to: platformDealId)
    }
    
    func dealsComplete(platformDealId: String) -> String {
        return relative(deals(platformDealId: platformDealId), to: "complete")
    }
    
    func dealsCancel(platformDealId: String) -> String {
        return relative(deals(platformDealId: platformDealId), to: "cancel")
    }
    
    func dealsBeneficiaryCard(platformDealId: String) -> String {
        return relative(deals(platformDealId: platformDealId), to: "beneficiaryCard")
    }
    
}

@objc public class DealsManager: Manager {
    
    /// Create money request for payer
    ///
    /// - Parameters:
    ///   - dealId: Deal identifier in your system
    ///   - payerId: Payer identifier in your system
    ///   - payerPhoneNumber: Phone number of payer
    ///   - card: Bank card, to which funds will be transferred
    ///   - amount: Amount of deal
    ///   - currencyId: Currency of deal
    ///   - shortDescription: Short description of deal
    ///   - fullDescription: Full description of deal
    ///   - complete: Completion handler with Object (Deal) id success and error if fail
    @discardableResult public func create(dealId: String, payerId: String, payerPhoneNumber: String, card: BankCard, amount: NSDecimalNumber, currencyId: CurrencyId, shortDescription: String, fullDescription: String, complete: @escaping (Deal?, Error?) -> Void) -> URLSessionDataTask {
        let parameters: [String: Any] = [
            "PlatformDealId": dealId,
            "PlatformPayerId": payerId,
            "PayerPhoneNumber": payerPhoneNumber,
            "PlatformBeneficiaryId": core.userId,
            "BeneficiaryCardId": card.cardId,
            "Amount": amount,
            "CurrencyId": currencyId.rawValue,
            "ShortDescription": shortDescription,
            "FullDescription": fullDescription
        ]
        return core.networkManager.request(URLComposer.default.deals(), method: .post, parameters: parameters, complete: complete)
    }
    
    /// Complete deal
    ///
    /// - Parameters:
    ///   - dealId: Deal identifier in your system
    ///   - complete: Completion handler with Object (Deal) id success and error if fail
    @discardableResult public func complete(dealId: String, complete: @escaping (Deal?, Error?) -> Void) -> URLSessionDataTask {
        return core.networkManager.request(URLComposer.default.dealsComplete(platformDealId: dealId), method: .put, parameters: nil, complete: complete)
    }
    
    /// Cancel deal
    ///
    /// - Parameters:
    ///   - dealId: Deal identifier in your system
    ///   - complete: Completion handler with Object (Deal) id success and error if fail
    @discardableResult public func cancel(dealId: String, complete: @escaping (Deal?, Error?) -> Void) -> URLSessionDataTask {
        return core.networkManager.request(URLComposer.default.dealsCancel(platformDealId: dealId), method: .put, parameters: nil, complete: complete)
    }
    
}
