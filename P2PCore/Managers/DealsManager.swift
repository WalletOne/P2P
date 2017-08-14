//
//  DealsManager.swift
//  P2P_iOS
//
//  Created by Vitaliy Kuzmenko on 17/07/2017.
//  Copyright © 2017 Wallet One. All rights reserved.
//

import Foundation

extension URLComposer {
 
    func deal() -> String {
        return relativeToBase("deal")
    }
    
    func dealPay() -> String {
        return relative(deal(), to: "pay")
    }
    
    func deals() -> String {
        return relativeToApi("deals")
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
    ///   - payerCardId: Bank card, to which funds will be transferred

    
    @discardableResult public func create(dealId: String, beneficiaryId: String, payerCardId: Int = 0, beneficiaryCardId: Int, amount: NSNumber, currencyId: CurrencyId, shortDescription: String, fullDescription: String, deferPayout: Bool, complete: @escaping (Deal?, Error?) -> Void) -> URLSessionDataTask {
        var parameters: [String: Any] = [
            "PlatformDealId": dealId,
            
            "PlatformPayerId": core.payerId,
            "PayerPhoneNumber": core.payerPhoneNumber,
            
            "PlatformBeneficiaryId": beneficiaryId,
            "BeneficiaryCardId": beneficiaryCardId,
            
            "Amount": amount,
            "CurrencyId": currencyId.rawValue,
            
            "ShortDescription": shortDescription,
            "FullDescription": fullDescription,
            
            "DeferPayout": deferPayout ? "true" : "false"
        ]
        
        if payerCardId != 0 {
            parameters["PayerCardId"] = payerCardId
        }
        
        return core.networkManager.request(URLComposer.default.deals(), method: .post, parameters: parameters, complete: complete)
    }
    
    /// Complete deal

    @discardableResult public func complete(dealId: String, complete: @escaping (Deal?, Error?) -> Void) -> URLSessionDataTask {
        return core.networkManager.request(URLComposer.default.dealsComplete(platformDealId: dealId), method: .put, parameters: nil, complete: complete)
    }
    
    /// Cancel deal
    
    @discardableResult public func cancel(dealId: String, complete: @escaping (Deal?, Error?) -> Void) -> URLSessionDataTask {
        return core.networkManager.request(URLComposer.default.dealsCancel(platformDealId: dealId), method: .put, parameters: nil, complete: complete)
    }
    
    /// Get deal status

    @discardableResult public func status(dealId: String, complete: @escaping (Deal?, Error?) -> Void) -> URLSessionDataTask {
        return core.networkManager.request(URLComposer.default.deals(platformDealId: dealId), method: .get, parameters: nil, complete: complete)
    }
    
    /// Change bank card in deal.
    /// This action acceptable when deal status one of (Created | PaymentProcessing | PaymentProcessError | Paid | PayoutProcessError)
    ///
    /// - Parameters:
    ///   - autoComplete: Perfrom transaction after the card has been updated

    @discardableResult public func set(bankCard: Int, for dealId: String, autoComplete: Bool, complete: @escaping (Deal?, Error?) -> Void) -> URLSessionDataTask {
        let parameters: [String: Any] = [
            "BeneficiaryCardId": bankCard,
            "AutoComplete": autoComplete
        ]
        return core.networkManager.request(URLComposer.default.dealsBeneficiaryCard(platformDealId: dealId), method: .put, parameters: parameters, complete: complete)
    }
    
    // Pay deal
    
    public func payRequest(dealId: String, redirectToCardAddition: Bool, authData: String? = nil, returnUrl: String) -> URLRequest {
        
        let urlString = URLComposer.default.dealPay()
        
        let url = URL(string: urlString)!
        
        let timeStamp = Date().ISO8601TimeStamp
        
        var items: [(key: String, value: String)] = [
            ("PlatformDealId", dealId),
            ("PlatformId", core.platformId),
            ("RedirectToCardAddition", redirectToCardAddition ? "true" : "false"),
            ("Timestamp", timeStamp),
            ("ReturnUrl", returnUrl)
        ]
        
        if let authData = authData {
            items.append(("AuthData", authData))
        }
        
        let signature = core.networkManager.makeSignatureForWeb(parameters: items)
        
        items.append(("Signature", signature))
        
        let queryString = items.map({ String(format: "%@=%@", $0.key, $0.value.urlEncode) }).joined(separator: "&")
        
        print(queryString)
        
        let queryData = queryString.data(using: .utf8)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = queryData
        
        return request
    }

    
}
